//
//  Widget.swift
//  Widget
//
//  Created by Yuuki on 2020/6/28.
//

import WidgetKit
import SwiftUI

struct MemoryWidgetEntry: TimelineEntry {
    //日期
    var date: Date
    //可用内存
    var freeCount: UInt64
    //活跃内存
    var activeCount: UInt64
    //非活跃内存
    var inactiveCount: UInt64
    //联动内存
    var wireCount: UInt64
    
    //格式化文字
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

// widget的数据源，它会告诉组件什么时候去渲染
struct MemoryWidgetProvider: TimelineProvider {
    // 此方法会在组件列表里显示，因此需要比较快速的生成对象
    func snapshot(with context: Context, completion: @escaping (MemoryWidgetEntry) -> ()) {
        let entry = MemoryWidgetEntry(date: Date(), freeCount: 0, activeCount: 0, inactiveCount: 0, wireCount: 0)
        completion(entry)
    }
    // 此方法提供实时数据，根据timeline的数组提供现在的和将来要更新的数据
    func timeline(with context: Context, completion: @escaping (Timeline<MemoryWidgetEntry>) -> ()) {
        let date = Date()
        //获取数据
        let (freeCount, activeCount, inactiveCount, wireCount) = DeviceUtil.getMemory()
        let entry = MemoryWidgetEntry(date: date, freeCount: freeCount, activeCount: activeCount, inactiveCount: inactiveCount, wireCount: wireCount)
        //下次更新的时间
        let nextDate = Calendar.current.date(byAdding: .second, value: 5, to: date)!
        //timeline对象 告诉Provider的更新策略
        let timelime = Timeline(entries: [entry], policy: .after(nextDate))
        completion(timelime)
        
    }
    
}

// SwiftUI构建的页面组件
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

// SwiftUI构建的页面组件
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

// SwiftUI构建的页面组件
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

// Widget对象 如果只提供一个组件 需要添加@main
struct MemoryWidget: Widget {
    // 唯一标识符
    private var kind = "MemoryWidget"
    public var body: some WidgetConfiguration {
        // 无配置的组件
        // kind: 唯一标识符
        // provider: 占位符
        // content: 实际的内容
        StaticConfiguration(kind: kind,
                            provider: MemoryWidgetProvider(),
                            placeholder: MemoryWidgetView(entry: MemoryWidgetEntry(date: Date(), freeCount: 0, activeCount: 0, inactiveCount: 0, wireCount: 0))) { entry in
            MemoryWidgetView(entry: entry)
        }
        .description("Show memory statistics") // 描述
        .configurationDisplayName("Memory statistics") // 展示名称
    }
}

// WidgetBundle可以提供多个Widget 使用需要添加@main
@main
struct DemoWidgetBundle:  WidgetBundle {
    
    // 有多个时需要添加
    @WidgetBundleBuilder
    var body: some Widget {
        MemoryWidget()
        DemoWidget()
    }
}
