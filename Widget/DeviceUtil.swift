//
//  DeviceUtil.swift
//  WidgetDemo
//
//  Created by Yuuki on 2020/6/28.
//

import Foundation

public class DeviceUtil {
    static func getMemory() -> (UInt64, UInt64, UInt64, UInt64) {
        
        let HOST_VM_INFO_COUNT = MemoryLayout<vm_statistics_data_t>.stride/MemoryLayout<integer_t>.stride;
        var size = mach_msg_type_number_t(HOST_VM_INFO_COUNT)
        var vm_stat = vm_statistics_data_t()
        let err: kern_return_t = withUnsafeMutableBytes(of: &vm_stat) {
            let boundBuffer = $0.bindMemory(to: Int32.self)
            
            return host_statistics(mach_host_self(), HOST_VM_INFO, boundBuffer.baseAddress, &size)
        }
        if err == KERN_SUCCESS {
            var pageSize = vm_size_t()
            
            host_page_size(mach_host_self(), &pageSize)
            
            return (UInt64(vm_stat.free_count) * UInt64(pageSize), UInt64(vm_stat.active_count) * UInt64(pageSize), UInt64(vm_stat.inactive_count) * UInt64(pageSize), UInt64(vm_stat.wire_count) * UInt64(pageSize))
        }
        
        return (0, 0, 0, 0)
        
    }
    
    static func getTotalMemorySize() -> UInt64 {
        return ProcessInfo.processInfo.physicalMemory
    }
}

public extension Double {
    func format(f: String) -> String {
        return String(format:"%\(f)f", self)
    }
}
