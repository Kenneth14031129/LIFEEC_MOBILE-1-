// controllers/userController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Register new user
exports.registerUser = async (req, res) => {
  try {
    const { fullName, email, password, phone, userType } = req.body;

    // Validate user type
    const validUserTypes = ['nurse', 'nutritionist', 'relative'];
    if (!validUserTypes.includes(userType)) {
      return res.status(400).json({ 
        message: 'Invalid user type. Must be nurse, nutritionist, or relative' 
      });
    }

    // Check if user exists
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    user = new User({
      fullName,
      email,
      password: hashedPassword,
      phone,
      userType
    });

    await user.save();

    res.status(201).json({
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        userType: user.userType
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ message: 'Server error during registration' });
  }
};

// Login user
exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Check if user exists
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Validate user type
    const validUserTypes = ['nurse', 'nutritionist', 'relative'];
    if (!validUserTypes.includes(user.userType)) {
      return res.status(400).json({ 
        message: 'Invalid user type. Please contact administrator' 
      });
    }

    // Validate password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    res.json({
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        userType: user.userType
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
};

// Get user profile
exports.getUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update user profile
exports.updateUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { fullName, email, phone } = req.body;

    // Check if email already exists for another user
    const existingUser = await User.findOne({ 
      email, 
      _id: { $ne: userId } 
    });
    
    if (existingUser) {
      return res.status(400).json({ 
        message: 'Email already in use by another account' 
      });
    }

    // Validate the data
    if (!fullName || !email) {
      return res.status(400).json({ 
        message: 'Full name and email are required' 
      });
    }

    // Email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ 
        message: 'Please provide a valid email address' 
      });
    }

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { 
        fullName, 
        email, 
        phone,
        updatedAt: Date.now()
      },
      { 
        new: true,
        runValidators: true 
      }
    ).select('-password');
    
    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json({
      message: 'Profile updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ 
      message: 'Server error during profile update',
      error: error.message 
    });
  }
};

// Delete user
exports.deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const deletedUser = await User.findByIdAndDelete(userId);
    
    if (!deletedUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ message: 'Server error during deletion' });
  }
};

// Change password
exports.changePassword = async (req, res) => {
  try {
    const { userId } = req.params;
    const { currentPassword, newPassword } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Verify current password
    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update password
    user.password = hashedPassword;
    await user.save();

    res.json({ message: 'Password updated successfully' });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ message: 'Server error during password change' });
  }
};

exports.getContactsList = async (req, res) => {
  try {
    // Get all users with specified roles
    const users = await User.find({
      userType: { 
        $in: ['admin','nurse', 'nutritionist', 'relative'] 
      }
    })
    .select('fullName userType email phone createdAt')
    .sort({ userType: 1, fullName: 1 });

    // Transform the data to match the contact list format
    const contacts = users.map(user => ({
      name: user.fullName,
      role: capitalizeFirstLetter(user.userType),
      lastMessage: "",
      lastMessageTime: new Date(),
      isOnline: false,
      email: user.email,
      phone: user.phone,
      userId: user._id
    }));

    // Group contacts by role
    const groupedContacts = contacts.reduce((acc, contact) => {
      if (!acc[contact.role]) {
        acc[contact.role] = [];
      }
      acc[contact.role].push(contact);
      return acc;
    }, {});

    res.status(200).json({
      success: true,
      contacts: groupedContacts
    });
  } catch (error) {
    console.error('Get contacts error:', error);
    res.status(500).json({
      success: false,
      message: 'Error retrieving contacts',
      error: error.message
    });
  }
};

// Helper function to capitalize first letter
function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

// Add this new function to get a specific user's contact details
exports.getContactDetails = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findById(userId)
      .select('fullName userType email phone createdAt');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Contact not found'
      });
    }

    const contact = {
      name: user.fullName,
      role: capitalizeFirstLetter(user.userType),
      email: user.email,
      phone: user.phone,
      userId: user._id,
      isOnline: false
    };

    res.status(200).json({
      success: true,
      contact
    });
  } catch (error) {
    console.error('Get contact details error:', error);
    res.status(500).json({
      success: false,
      message: 'Error retrieving contact details',
      error: error.message
    });
  }
};