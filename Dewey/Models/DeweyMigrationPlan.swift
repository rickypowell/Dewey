import SwiftData

/// The migration plan is important if we decide to add more models
/// or change the ones that are currently there. I have learned from experience
/// that it is super important to have this in place before your first app release.
enum DeweyMigrationPlan: SchemaMigrationPlan {

    static let schemas: [any VersionedSchema.Type] = [
        DeweySchemaV1.self,
    ]

    static let stages: [MigrationStage] = []
}
