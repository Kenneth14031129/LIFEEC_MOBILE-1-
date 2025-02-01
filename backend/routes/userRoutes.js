// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/auth');

// Public routes
router.post('/register', userController.registerUser);
router.post('/login', userController.loginUser);

// Protected routes (require authentication)
router.get('/profile', auth, userController.getUserProfile);
router.put('/update', auth, userController.updateUser);
router.delete('/delete', auth, userController.deleteUser);

module.exports = router;