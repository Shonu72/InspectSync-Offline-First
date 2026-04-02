// Stub implementation representing the backend server or API client
class TaskRemoteDataSource {
  Future<void> syncTaskUpdateToServer(String payload) async {
    // API call logic here.
    // E.g., await api.post('/tasks/update', data: payload);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> syncTaskCreateToServer(String payload) async {
    // API call logic here.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<dynamic> fetchLatestServerTaskData(String taskId) async {
    // Return latest JSON from server representation
    return {};
  }
}
