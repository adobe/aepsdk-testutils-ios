//
// Copyright 2020 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

@testable import AEPServices
import Foundation

public extension FileManager {
    func clearCache() {
        let knownCacheItems: [String] = ["com.adobe.edge", "com.adobe.edge.identity", "com.adobe.edge.consent"]
        guard let url = self.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }

        for cacheItem in knownCacheItems {
            do {
                try self.removeItem(at: URL(fileURLWithPath: "\(url.relativePath)/\(cacheItem)"))
                if let dqService = ServiceProvider.shared.dataQueueService as? DataQueueService {
                    _ = dqService.threadSafeDictionary.removeValue(forKey: cacheItem)
                }
            } catch {
                print("ERROR DESCRIPTION: \(error)")
            }
        }
    }
    
    /// Removes the Adobe-specific directory within the app's data storage (persistence). This method attempts to locate and delete the 
    /// `com.adobe.aep.datastore` directory either in the specified app group's container directory or in the default library directory 
    /// if no app group is provided.
    ///
    /// - Parameter appGroup: An optional `String` representing the app group identifier. If provided, the method will look for the Adobe directory within the shared container for that app group. If `nil`, the method will search for the directory in the user's library directory across all domains the app has access to.
    ///
    /// - Requires: Before calling this method, ensure that the caller has the appropriate permissions to access and modify the file system, especially if working with app group directories.
    func removeAdobeDirectory(appGroup: String?) {
        let LOG_TAG = "FileManager"
        let adobeDirectory = "com.adobe.aep.datastore"
        let fileManager = FileManager.default

        // Recreate the directory URL
        var directoryUrl: URL?
        if let appGroup = appGroup {
            directoryUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
                .appendingPathComponent(adobeDirectory, isDirectory: true)
        } else {
            directoryUrl = fileManager.urls(for: .libraryDirectory, in: .allDomainsMask).first?
                .appendingPathComponent(adobeDirectory, isDirectory: true)
        }

        guard let directoryUrl = directoryUrl else {
            Log.error(label: LOG_TAG, "Could not compute the directory URL for removal.")
            return
        }
        
        // Remove the directory
        do {
            try fileManager.removeItem(at: directoryUrl)
            Log.debug(label: LOG_TAG, "Successfully removed directory at \(directoryUrl.path).")
        } catch {
            Log.warning(label: LOG_TAG, "Failed to remove directory at \(directoryUrl.path) with error: \(error)")
        }
    }
}
