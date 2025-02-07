// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// All routes are now public
router.post('/register', userController.registerUser);
router.post('/login', userController.loginUser);
router.get('/profile/:userId', userController.getUserProfile);
router.put('/update/:userId', userController.updateUser);
router.delete('/delete', userController.deleteUser);
router.put('/change-password/:userId', userController.changePassword);
router.get('/contacts', userController.getContactsList);
router.get('/contacts/:userId', userController.getContactDetails);

module.exports = router;