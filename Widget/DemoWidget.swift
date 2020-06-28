//
//  DemoWidget.swift
//  WidgetDemo
//
//  Created by Yuuki on 2020/6/28.
//

import SwiftUI
import WidgetKit

struct DemoEntry: TimelineEntry {
    var date: Date
}

struct DemoProvider: TimelineProvider {
    func snapshot(with context: Context, completion: @escaping (DemoEntry) -> ()) {
        completion(DemoEntry(date: Date()))
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<DemoEntry>) -> ()) {
        let date = Date()
        let nextDate = Calendar.current.date(byAdding: .minute, value: 1, to: date)!
        let entry = DemoEntry(date: date)
        let timeline = Timeline(entries: [entry], policy: .after(nextDate))
        completion(timeline)
    }
}

struct DemoView: View {
    var entry: DemoEntry
    var body: some View {
        Text("Demo \(entry.date)")
    }
}

struct DemoWidget: Widget {
    private let kind: String = "DemoWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DemoProvider(), placeholder: DemoView(entry: DemoEntry(date: Date()))) { entry in
            DemoView(entry: entry)
        }
        .configurationDisplayName("Demo Widget")
        .description("This is another widget")
    }
}
