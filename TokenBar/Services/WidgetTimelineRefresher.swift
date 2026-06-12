import Foundation
import WidgetKit

enum WidgetTimelineRefresher {
    static func reload() {
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.widgetKind)
    }
}
