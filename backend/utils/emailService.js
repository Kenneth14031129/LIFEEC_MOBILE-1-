// utils/emailService.js
const nodemailer = require('nodemailer');

// Create reusable transporter with better error handling and configuration
const createTransporter = async () => {
  // Production transporter
  const prodTransporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
    // Add these settings to handle gmail requirements
    tls: {
      rejectUnauthorized: false
    },
    // Set higher timeout
    connectionTimeout: 10000,
    // Retry settings
    pool: true,
    maxConnections: 3,
    maxMessages: 100,
    rateDelta: 1000,
    rateLimit: 5
  });

  // Verify the connection configuration
  try {
    await prodTransporter.verify();
    console.log('Email transporter verified successfully');
    return prodTransporter;
  } catch (error) {
    console.error('Email transporter verification failed:', error);
    throw error;
  }
};

// Enhanced sendOTP function with better error handling
const sendOTP = async (email, otp) => {
  try {
    const transporter = await createTransporter();
    
    const mailOptions = {
      from: {
        name: 'LIFEEC Support',
        address: process.env.EMAIL_USER
      },
      to: email,
      subject: 'LIFEEC - Email Verification OTP',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #2196f3;">LIFEEC Email Verification</h2>
          <p>Your verification code is:</p>
          <h1 style="color: #1976d2; font-size: 36px; letter-spacing: 5px;">${otp}</h1>
          <p>This code will expire in 10 minutes.</p>
          <p>If you didn't request this code, please ignore this email.</p>
        </div>
      `,
      // Add these headers to improve deliverability
      headers: {
        'X-Priority': '1',
        'X-MSMail-Priority': 'High',
        'Importance': 'high'
      }
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', info.messageId);
    return true;
  } catch (error) {
    console.error('Detailed email sending error:', {
      error: error.message,
      code: error.code,
      command: error.command,
      recipient: email
    });
    return false;
  }
};

// Enhanced emergency alert email sender with retry logic
const sendEmergencyEmail = async (recipient, residentName, message, retries = 3) => {
  const mailOptions = {
    from: {
      name: 'LIFEEC Emergency Alerts',
      address: process.env.EMAIL_USER
    },
    to: recipient,
    subject: `URGENT: Emergency Alert for ${residentName}`,
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #dc3545;">Emergency Alert</h2>
        <div style="background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 4px; margin: 20px 0;">
          <p><strong>Resident:</strong> ${residentName}</p>
          <p><strong>Message:</strong> ${message}</p>
          <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
        </div>
        <p style="color: #721c24;"><strong>Important:</strong> Please check the LIFEEC app for more details and required actions.</p>
        <hr style="border: 0; border-top: 1px solid #ddd; margin: 20px 0;">
        <p style="color: #666; font-size: 12px;">This is an automated emergency alert. Please do not reply to this email.</p>
      </div>
    `,
    priority: 'high',
    headers: {
      'X-Priority': '1',
      'X-MSMail-Priority': 'High',
      'Importance': 'high'
    }
  };

  for (let attempt = 1; attempt <= retries; attempt++) {
    try {
      const transporter = await createTransporter();
      const info = await transporter.sendMail(mailOptions);
      console.log(`Emergency email sent successfully to ${recipient}:`, info.messageId);
      return true;
    } catch (error) {
      console.error(`Attempt ${attempt} failed for ${recipient}:`, error);
      if (attempt === retries) {
        console.error(`All ${retries} attempts failed for ${recipient}`);
        return false;
      }
      // Wait before retrying (exponential backoff)
      await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
    }
  }
};

module.exports = { sendOTP, sendEmergencyEmail };