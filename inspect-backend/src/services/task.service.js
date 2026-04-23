const prisma = require('../config/db');
const ApiError = require('../utils/ApiError');

const createTask = async (taskData, userId) => {
  return await prisma.task.create({
    data: {
      ...taskData,
      createdById: userId,
      version: 1
    }
  });
};

const getTasks = async (filters = {}) => {
  const { status, priority, assignedToId } = filters;
  return await prisma.task.findMany({
    where: {
      deletedAt: null,
      ...(status && { status }),
      ...(priority && { priority }),
      ...(assignedToId && { assignedToId })
    },
    include: {
      createdBy: { select: { id: true, name: true, email: true } },
      assignedTo: { select: { id: true, name: true, email: true } }
    },
    orderBy: { updatedAt: 'desc' }
  });
};

const getTaskById = async (id) => {
  const task = await prisma.task.findUnique({
    where: { id },
    include: {
      createdBy: { select: { id: true, name: true, email: true } },
      assignedTo: { select: { id: true, name: true, email: true } }
    }
  });
  if (!task) throw new ApiError(404, 'Task not found');
  return task;
};

const updateTask = async (id, updateData, clientVersion) => {
  const task = await prisma.task.findUnique({ where: { id } });
  if (!task) throw new ApiError(404, 'Task not found');

  // Conflict Detection: If client version is behind server version
  if (clientVersion && clientVersion < task.version) {
    throw new ApiError(409, 'Conflict detected: Server has a/Users/shouryasonu/Development/inspectSync/inspectsync-backend/src/services/task.service.js newer version of this task', false, {
      serverVersion: task.version,
      serverData: task
    });
  }

  return await prisma.task.update({
    where: { id },
    data: {
      ...updateData,
      version: { increment: 1 },
      clientUpdatedAt: updateData.clientUpdatedAt ? new Date(updateData.clientUpdatedAt) : undefined
    }
  });
};

const deleteTask = async (id) => {
  const task = await prisma.task.findUnique({ where: { id } });
  if (!task) throw new ApiError(404, 'Task not found');
  
  // Soft delete: update deletedAt instead of destroying the record
  return await prisma.task.update({
    where: { id },
    data: { deletedAt: new Date() }
  });
};

module.exports = {
  createTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask
};
