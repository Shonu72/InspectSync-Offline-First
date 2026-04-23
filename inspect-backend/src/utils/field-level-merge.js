const _ = require('lodash');

/**
 * Merges client data into server data using a field-level merge strategy.
 * Implements Last-Write-Wins (LWW) for each field.
 * 
 * @param {Object} serverData - The current state in the database
 * @param {Object} clientData - The incoming data from the mobile device
 * @returns {Object} - The merged object to be saved
 */
const mergeFields = (serverData, clientData) => {
  // Fields that should never be overwritten by a client sync update
  const systemFields = ['id', 'version', 'createdAt', 'updatedAt', 'createdById', 'assignedToId'];

  const merged = {};

  // 1. Start with updateable fields from the server
  Object.keys(serverData).forEach((key) => {
    if (!systemFields.includes(key) && serverData[key] !== undefined) {
      merged[key] = serverData[key];
    }
  });

  // 2. Overwrite with fields from the client (LWW)
  Object.keys(clientData).forEach((key) => {
    if (!systemFields.includes(key) && clientData[key] !== undefined) {
      merged[key] = clientData[key];
    }
  });

  return merged;
};

module.exports = {
  mergeFields
};
