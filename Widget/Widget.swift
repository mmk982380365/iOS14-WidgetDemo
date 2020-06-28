//
//  Widget.swift
//  Widget
//
//  Created by Yuuki on 2020/6/28.
//

import WidgetKit
import SwiftUI

struct MemoryWidgetEntry: TimelineEntry {
    
    var date: Date
    var freeCount: UInt64
    var activeCount: UInt64
    var inactiveCount: UInt64
    var wireCount: UInt64
    
    var freeCountDescription: String {
        return "\((Double(freeCount) / 1024.0 / 1024.0).format(f: ".2")) MB"
    }
    
    var activeCountDescription: String {
        return "\((Double(activeCount) / 1024.0 / 1024.0).format(f: ".2")) MB"
    }
    
    var inactiveCountDescription: String {
        return "\((Double(inactiveCount) / 1024.0 / 1024.0).format(f: ".2")) MB"
    }
    
    var wireCountDescription: String {
        return "\((Double(wireCount) / 1024.0 / 1024.0).format(f: ".2")) MB"
    }
    
}

struct MemoryWidgetProvider: TimelineProvider {
    
    func snapshot(with context: Context, completion: @escaping (MemoryWidgetEntry) -> ()) {
        let (freeCount, activeCount, inactiveCount, wireCount) = DeviceUtil.getMemory()
        let entry = MemoryWidgetEntry(date: Date(), freeCount: freeCount, activeCount: activeCount, inactiveCount: inactiveCount, wireCount: wireCount)
        completion(entry)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<MemoryWidgetEntry>) -> ()) {
        let date = Date()
        let (freeCount, activeCount, inactiveCount, wireCount) = DeviceUtil.getMemory()
        let entry = MemoryWidgetEntry(date: date, freeCount: freeCount, activeCount: activeCount, inactiveCount: inactiveCount, wireCount: wireCount)
        
        let nextDate = Calendar.current.date(byAdding: .second, value: 5, to: date)!
        let timelime = Timeline(entries: [entry], policy: .after(nextDate))
        completion(timelime)
        
    }
    
}

struct MemoryWidgetRow: View {
    var title: String
    var desc: String
    
    
    var body: some View {
        HStack {
            Text("\(title):").font(.system(size: 12))
            Spacer()
            Text("\(desc)").font(.system(size: 12))
        }
    }
}

struct MemoryWidgetProgress: View {
    var progress: Double
    func actualProgress() -> CGFloat {
        if progress < 0 {
            return 0
        } else if progress > 1 {
            return 1
        }
        return CGFloat(progress)
    }
    var body: some View {
        HStack {
            GeometryReader { geometry in
                Path { path in
                    path.move(to: CGPoint(x: 0.0, y: 2.0))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: 2.0))
                }.stroke(lineWidth: 4.0).foregroundColor(.gray)
                Path { path in
                    path.move(to: CGPoint(x: 0.0, y: 2.0))
                    path.addLine(to: CGPoint(x: geometry.size.width * actualProgress(), y: 2.0))
                }.stroke(lineWidth: 4.0).foregroundColor(.red)
            }.fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct MemoryWidgetView: View {
    var entry: MemoryWidgetEntry
    let totalMemory = Double(DeviceUtil.getTotalMemorySize())
    var body: some View {
        VStack(spacing: 3) {
            MemoryWidgetRow(title: "Free", desc: entry.freeCountDescription)
            MemoryWidgetProgress(progress: Double(entry.freeCount) / totalMemory)
            MemoryWidgetRow(title: "Active", desc: entry.activeCountDescription)
            MemoryWidgetProgress(progress: Double(entry.activeCount) / totalMemory)
            MemoryWidgetRow(title: "Inactive", desc: entry.inactiveCountDescription)
            MemoryWidgetProgress(progress: Double(entry.inactiveCount) / totalMemory)
            MemoryWidgetRow(title: "Wire", desc: entry.wireCountDescription)
            MemoryWidgetProgress(progress: Double(entry.wireCount) / totalMemory)
            
            MemoryWidgetRow(title: "Total", desc: "\((self.totalMemory / 1024.0 / 1024.0).format(f: ".2")) MB").foregroundColor(.blue)
            
        }.padding()
    }
}

struct MemoryWidget: Widget {
    private var kind = "MemoryWidget"
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: MemoryWidgetProvider(),
                            placeholder: MemoryWidgetView(entry: MemoryWidgetEntry(date: Date(), freeCount: 0, activeCount: 0, inactiveCount: 0, wireCount: 0))) { entry in
            MemoryWidgetView(entry: entry)
        }
        .description("Show memory statistics")
        .configurationDisplayName("Memory statistics")
    }
}

struct MemoryWidgetPreviewer: PreviewProvider {
    static var previews: some View {
        Text("Demo")
    }
}

@main
struct DemoWidgetBundle:  WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        MemoryWidget()
        DemoWidget()
    }
}
