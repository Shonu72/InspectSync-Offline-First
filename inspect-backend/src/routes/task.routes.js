const express = require('express');
const taskController = require('../controllers/task.controller');
const auth = require('../middleware/auth');

const router = express.Router();

router.use(auth); // All task routes require authentication

router.post('/', taskController.createTask);
router.get('/', taskController.getTasks);
router.get('/:id', taskController.getTaskById);
router.put('/:id', taskController.updateTask);
router.delete('/:id', taskController.deleteTask);

module.exports = router;
