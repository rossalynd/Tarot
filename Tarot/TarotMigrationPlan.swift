//
//  TarotMigrationPlan.swift
//  Tarot
//
//  Created by Rosie on 6/27/26.
//


//
//  TarotMigrationPlan.swift
//  Tarot
//

import SwiftData

enum TarotMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            TarotSchemaV1.self,
            TarotSchemaV2.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2
        ]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: TarotSchemaV1.self,
        toVersion: TarotSchemaV2.self
    )
}