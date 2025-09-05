//
//  CategoryEntity+CoreDataProperties.swift
//  Screenshot
//
//  Created by Michael Carruthers on 9/4/25.
//
//

import Foundation
import CoreData


extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isSystem: Bool
    @NSManaged public var name: String?
    @NSManaged public var sortOrder: Int64
    @NSManaged public var screenshots: NSSet?

}

// MARK: Generated accessors for screenshots
extension CategoryEntity {

    @objc(addScreenshotsObject:)
    @NSManaged public func addToScreenshots(_ value: ScreenshotEntity)

    @objc(removeScreenshotsObject:)
    @NSManaged public func removeFromScreenshots(_ value: ScreenshotEntity)

    @objc(addScreenshots:)
    @NSManaged public func addToScreenshots(_ values: NSSet)

    @objc(removeScreenshots:)
    @NSManaged public func removeFromScreenshots(_ values: NSSet)

}

extension CategoryEntity : Identifiable {

}
