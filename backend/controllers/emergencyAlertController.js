// controllers/emergencyAlertController.js
const EmergencyAlert = require('../models/EmergencyAlert');
const Resident = require('../models/Resident');
const User = require('../models/User');
const nodemailer = require('nodemailer');

// Email configuration
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

// Helper function to format date
const formatDate = (date) => {
  return new Date(date).toLocaleString('en-US', {
    dateStyle: 'medium',
    timeStyle: 'short'
  });
};

// Helper function to send email notifications
async function sendEmailNotification(recipient, residentName, message) {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: recipient,
    subject: `URGENT: Emergency Alert for ${residentName}`,
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #dc3545;">Emergency Alert</h2>
        <div style="background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 4px; margin: 20px 0;">
          <p><strong>Resident:</strong> ${residentName}</p>
          <p><strong>Message:</strong> ${message}</p>
          <p><strong>Time:</strong> ${formatDate(new Date())}</p>
        </div>
        <p style="color: #721c24;"><strong>Important:</strong> Please check the LIFEEC app for more details and required actions.</p>
        <hr style="border: 0; border-top: 1px solid #ddd; margin: 20px 0;">
        <p style="color: #666; font-size: 12px;">This is an automated emergency alert. Please do not reply to this email.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Email notification sent to ${recipient}`);
    return true;
  } catch (error) {
    console.error(`Failed to send email to ${recipient}:`, error);
    return false;
  }
}

// Helper function to notify all relevant users
async function notifyRelevantUsers(resident, alert) {
  try {
    // Get all nurses, admins, and owners
    const staffUsers = await User.find({
      userType: { $in: ['nurse', 'admin', 'owner'] },
      isArchived: false,
      isVerified: true
    });

    // Get relative(s) associated with the resident
    const relatives = await User.find({
      userType: 'relative',
      isArchived: false,
      isVerified: true,
      associatedResident: resident._id
    });

    // Combine all users to notify
    const usersToNotify = [...staffUsers, ...relatives];

    // Send email notifications
    const emailPromises = usersToNotify.map(user => 
      sendEmailNotification(
        user.email,
        resident.fullName,
        alert.message
      )
    );

    // Wait for all emails to be sent
    const emailResults = await Promise.allSettled(emailPromises);
    const successfulEmails = emailResults.filter(result => result.status === 'fulfilled').length;

    return {
      notifiedUsers: usersToNotify.length,
      staffNotified: staffUsers.length,
      relativesNotified: relatives.length,
      emailsSent: successfulEmails
    };
  } catch (error) {
    console.error('Error in notifyRelevantUsers:', error);
    throw error;
  }
}

// Create new emergency alert
exports.createEmergencyAlert = async (req, res) => {
  try {
    const { residentId } = req.body;

    // Find resident to get their details
    const resident = await Resident.findById(residentId);
    if (!resident) {
      return res.status(404).json({ message: 'Resident not found' });
    }

    // Create emergency alert
    const emergencyAlert = new EmergencyAlert({
      residentId: resident._id,
      residentName: resident.fullName,
      message: `Emergency alert triggered for ${resident.fullName}`,
      emergencyContact: {
        name: resident.emergencyContact.name,
        phone: resident.emergencyContact.phone,
        email: resident.emergencyContact.email,
        relation: resident.emergencyContact.relation
      }
    });

    await emergencyAlert.save();

    // Notify all relevant users
    const notificationResults = await notifyRelevantUsers(resident, emergencyAlert);

    // Also send to emergency contact if provided
    let emergencyContactNotified = false;
    if (resident.emergencyContact.email) {
      emergencyContactNotified = await sendEmailNotification(
        resident.emergencyContact.email,
        resident.fullName,
        emergencyAlert.message
      );
    }

    res.status(201).json({ 
      message: 'Emergency alert created and notifications sent successfully',
      alert: emergencyAlert,
      notificationStats: {
        ...notificationResults,
        emergencyContactNotified
      }
    });
  } catch (error) {
    console.error('Error creating emergency alert:', error);
    res.status(500).json({ 
      message: 'Error creating emergency alert',
      error: error.message 
    });
  }
};

// Get all emergency alerts
exports.getEmergencyAlerts = async (req, res) => {
  try {
    const alerts = await EmergencyAlert.find()
      .sort({ timestamp: -1 })
      .populate('residentId', 'fullName');

    res.status(200).json(alerts);
  } catch (error) {
    console.error('Error fetching emergency alerts:', error);
    res.status(500).json({ 
      message: 'Error fetching emergency alerts',
      error: error.message 
    });
  }
};

// Get emergency alerts for a specific resident
exports.getEmergencyAlertsByResident = async (req, res) => {
  try {
    const { residentId } = req.params;
    
    const alerts = await EmergencyAlert.find({ residentId })
      .sort({ timestamp: -1 })
      .populate('residentId', 'fullName');

    res.status(200).json(alerts);
  } catch (error) {
    console.error('Error fetching resident emergency alerts:', error);
    res.status(500).json({ 
      message: 'Error fetching resident emergency alerts',
      error: error.message 
    });
  }
};

// Mark alert as read
exports.markAlertAsRead = async (req, res) => {
  try {
    const { alertId } = req.params;
    
    const alert = await EmergencyAlert.findByIdAndUpdate(
      alertId,
      { read: true },
      { new: true }
    );
    
    if (!alert) {
      return res.status(404).json({ message: 'Alert not found' });
    }
    
    res.status(200).json({
      message: 'Alert marked as read',
      alert
    });
  } catch (error) {
    console.error('Error marking alert as read:', error);
    res.status(500).json({ 
      message: 'Error updating alert status',
      error: error.message 
    });
  }
};

// Delete alerts older than 24 hours
exports.deleteOldAlerts = async (req, res) => {
  try {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    const result = await EmergencyAlert.deleteMany({
      timestamp: { $lt: twentyFourHoursAgo }
    });

    res.status(200).json({
      message: 'Old alerts deleted successfully',
      deletedCount: result.deletedCount
    });
  } catch (error) {
    console.error('Error deleting old alerts:', error);
    res.status(500).json({ 
      message: 'Error deleting old alerts',
      error: error.message 
    });
  }
};

// Get unread alerts count
exports.getUnreadAlertsCount = async (req, res) => {
  try {
    const count = await EmergencyAlert.countDocuments({ read: false });
    
    res.status(200).json({
      unreadCount: count
    });
  } catch (error) {
    console.error('Error getting unread alerts count:', error);
    res.status(500).json({ 
      message: 'Error getting unread alerts count',
      error: error.message 
    });
  }
};