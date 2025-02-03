// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// All routes are now public
router.post('/register', userController.registerUser);
router.post('/login', userController.loginUser);
router.get('/profile', userController.getUserProfile);
router.put('/update', userController.updateUser);
router.delete('/delete', userController.deleteUser);

module.exports = router;