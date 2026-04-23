const syncService = require('../services/sync.service');

const pull = async (req, res, next) => {
  try {
    const { since } = req.query;
    const data = await syncService.pullChanges(since, req.user.id);
    res.json({
      success: true,
      data
    });
  } catch (error) {
    next(error);
  }
};

const push = async (req, res, next) => {
  try {
    const { 
      device_id, 
      deviceId, 
      last_synced_at, 
      lastSyncedAt,
      changes, 
      batch 
    } = req.body;

    const currentChanges = changes || batch;
    const currentDeviceId = device_id || deviceId;
    const currentLastSyncedAt = last_synced_at || lastSyncedAt;

    if (!Array.isArray(currentChanges)) {
      return res.status(400).json({ success: false, message: 'Changes/Batch must be an array' });
    }

    if (!currentDeviceId) {
      return res.status(400).json({ success: false, message: 'device_id is required' });
    }
    
    const results = await syncService.pushChanges({ 
      device_id: currentDeviceId, 
      last_synced_at: currentLastSyncedAt, 
      changes: currentChanges 
    }, req.user.id);

    res.json({
      success: true,
      data: results
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  pull,
  push
};
