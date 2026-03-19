String generateIdempotencyKey(String actionType, String todoId) {
  return "$actionType-$todoId";
}