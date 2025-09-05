//
//  ScreenshotEntity+CoreDataProperties.swift
//  Screenshot
//
//  Created by Michael Carruthers on 9/4/25.
//
//

import Foundation
import CoreData


extension ScreenshotEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScreenshotEntity> {
        return NSFetchRequest<ScreenshotEntity>(entityName: "ScreenshotEntity")
    }

    @NSManaged public var category: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var ocrText: String?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var fullImagePath: String?
    @NSManaged public var status: String?
    @NSManaged public var assetIdentifier: String?
    @NSManaged public var folder: CategoryEntity?

}

extension ScreenshotEntity : Identifiable {

}
