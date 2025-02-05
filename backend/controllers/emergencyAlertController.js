// controllers/emergencyAlertController.js
const EmergencyAlert = require('../models/EmergencyAlert');
const Resident = require('../models/Resident');

exports.createEmergencyAlert = async (req, res) => {
  try {
    const { residentId } = req.body;

    // Find resident to get their details
    const resident = await Resident.findById(residentId);
    if (!resident) {
      return res.status(404).json({ message: 'Resident not found' });
    }

    const emergencyAlert = new EmergencyAlert({
      residentId: resident._id,
      residentName: resident.fullName,
      emergencyContact: {
        name: resident.emergencyContact.name,
        phone: resident.emergencyContact.phone,
        email: resident.emergencyContact.email,
        relation: resident.emergencyContact.relation
      }
    });

    await emergencyAlert.save();

    // Here you could add notification logic (email, SMS, etc.)
    // await sendEmergencyNotification(emergencyAlert);

    res.status(201).json({ 
      message: 'Emergency alert created successfully',
      alert: emergencyAlert 
    });
  } catch (error) {
    console.error('Error creating emergency alert:', error);
    res.status(500).json({ 
      message: 'Error creating emergency alert',
      error: error.message 
    });
  }
};

exports.getEmergencyAlerts = async (req, res) => {
  try {
    const alerts = await EmergencyAlert.find()
      .sort({ timestamp: -1 });
    res.status(200).json(alerts);
  } catch (error) {
    res.status(500).json({ 
      message: 'Error fetching emergency alerts',
      error: error.message 
    });
  }
};

exports.getEmergencyAlertsByResident = async (req, res) => {
  try {
    const { residentId } = req.params;
    const alerts = await EmergencyAlert.find({ residentId })
      .sort({ timestamp: -1 });
    res.status(200).json(alerts);
  } catch (error) {
    res.status(500).json({ 
      message: 'Error fetching resident emergency alerts',
      error: error.message 
    });
  }
};

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
    
    res.status(200).json(alert);
  } catch (error) {
    res.status(500).json({ 
      message: 'Error updating alert status',
      error: error.message 
    });
  }
};