extension String {
  static func pluralize(
    _ count: Int, _ singular: String, _ plural: String? = nil
  ) -> String {
    if count == 1 {
      return singular
    }
    return plural ?? "\(singular)s"
  }
} 
