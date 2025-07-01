#!/usr/bin/env python3
"""
Mushak Debug Analyzer - Advanced system debugging tools
"""

import re
import json
import subprocess
import psutil
from pathlib import Path
from typing import Dict, List, Optional, Any

class MusakDebugAnalyzer:
    def __init__(self):
        self.log_patterns = {
            'errors': r'ERROR|FATAL|CRITICAL',
            'warnings': r'WARNING|WARN',
            'memory_leak': r'OutOfMemoryError|MemoryError|heap.*overflow',
            'performance_issues': r'slow.*query|timeout|performance',
            'security_concerns': r'authentication.*failed|unauthorized|permission.*denied'
        }
    
    def analyze_system_logs(self, log_path: str = '/var/log') -> Dict[str, List[str]]:
        """Analyze system logs for issues and patterns"""
        issues: Dict[str, List[str]] = {
            'errors': [],
            'warnings': [],
            'performance_issues': [],
            'security_concerns': [],
            'memory_leaks': []
        }
        
        log_files = list(Path(log_path).rglob('*.log'))
        
        for log_file in log_files:
            try:
                with open(log_file, 'r', errors='ignore') as f:
                    content = f.read()
                    
                    # Pattern matching for different issue types
                    for category, pattern in self.log_patterns.items():
                        matches = re.findall(pattern, content, re.IGNORECASE)
                        if matches:
                            issues[category].extend([
                                f"{log_file}: {match}" 
                                for match in matches[:10]  # Limit matches per file
                            ])
            except Exception as e:
                continue
        
        return issues
    
    def check_system_performance(self) -> Dict[str, Any]:
        """Comprehensive system performance analysis"""
        return {
            'cpu_usage': psutil.cpu_percent(interval=1, percpu=True),
            'memory_usage': psutil.virtual_memory()._asdict(),
            'disk_usage': psutil.disk_usage('/')._asdict(),
            'network_io': psutil.net_io_counters()._asdict(),
            'process_count': len(psutil.pids()),
            'load_avg': psutil.getloadavg() if hasattr(psutil, 'getloadavg') else None,
            'boot_time': psutil.boot_time(),
            'cpu_stats': psutil.cpu_stats()._asdict() if hasattr(psutil, 'cpu_stats') else {},
            'cpu_freq': psutil.cpu_freq()._asdict() if hasattr(psutil, 'cpu_freq') else {},
            'swap_memory': psutil.swap_memory()._asdict(),
            'disk_io': psutil.disk_io_counters()._asdict() if hasattr(psutil, 'disk_io_counters') else {}
        }
    
    def detect_memory_leaks(self) -> List[Dict[str, Any]]:
        """Detect potential memory leaks in running processes"""
        suspicious_processes = []
        
        for proc in psutil.process_iter(['pid', 'name', 'memory_info', 'cmdline', 'create_time']):
            try:
                pinfo = proc.info
                memory_mb = pinfo['memory_info'].rss / (1024 * 1024)  # Convert to MB
                
                if memory_mb > 1000:  # Processes using >1GB RAM
                    suspicious_processes.append({
                        'pid': pinfo['pid'],
                        'name': pinfo['name'],
                        'memory_mb': round(memory_mb, 2),
                        'cmdline': ' '.join(pinfo['cmdline'] or [])[:200],  # Truncate long command lines
                        'uptime': int(psutil.time.time() - pinfo['create_time']),
                        'cpu_percent': proc.cpu_percent(interval=0.1)
                    })
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue
        
        return sorted(suspicious_processes, key=lambda x: x['memory_mb'], reverse=True)[:20]

    def suggest_optimizations(self, performance_data: Dict) -> List[str]:
        """Generate optimization suggestions based on system analysis"""
        suggestions = []
        
        # CPU analysis
        cpu_avg = sum(performance_data['cpu_usage']) / len(performance_data['cpu_usage']) if isinstance(performance_data['cpu_usage'], list) else performance_data['cpu_usage']
        if cpu_avg > 80:
            suggestions.append(
                "⚡ High CPU usage detected ({}%) - Consider identifying and terminating "
                "resource-intensive processes".format(round(cpu_avg, 1))
            )
        
        # Memory analysis
        mem = performance_data['memory_usage']
        if mem['percent'] > 85:
            suggestions.append(
                "🧠 High memory usage ({}% of {} GB) - Consider enabling ZRAM, "
                "adding swap space, or identifying memory leaks".format(
                    mem['percent'],
                    round(mem['total'] / (1024**3), 1)
                )
            )
        
        # Disk analysis
        disk = performance_data['disk_usage']
        if disk['percent'] > 90:
            suggestions.append(
                "💾 Disk space critically low ({}% used of {} GB) - "
                "Clean temporary files, logs, and consider expanding storage".format(
                    disk['percent'],
                    round(disk['total'] / (1024**3), 1)
                )
            )
        
        # Process analysis
        if performance_data.get('process_count', 0) > 200:
            suggestions.append(
                f"🔄 High number of running processes ({performance_data['process_count']}) - "
                "Review and disable unnecessary services"
            )
        
        return suggestions

    def get_system_info(self) -> Dict[str, Any]:
        """Get comprehensive system information"""
        return {
            'system': {
                'platform': platform.system(),
                'platform_version': platform.version(),
                'machine': platform.machine(),
                'processor': platform.processor(),
                'hostname': platform.node(),
            },
            'python': {
                'version': platform.python_version(),
                'implementation': platform.python_implementation(),
                'compiler': platform.python_compiler(),
            },
            'boot_time': psutil.boot_time(),
            'users': [u._asdict() for u in psutil.users()],
        }

if __name__ == "__main__":
    import platform
    analyzer = MusakDebugAnalyzer()
    
    print("=== System Performance ===")
    perf_data = analyzer.check_system_performance()
    print(json.dumps(perf_data, indent=2, default=str))
    
    print("\n=== Optimization Suggestions ===")
    for suggestion in analyzer.suggest_optimizations(perf_data):
        print(f"- {suggestion}")
    
    print("\n=== Suspicious Processes ===")
    processes = analyzer.detect_memory_leaks()
    print(json.dumps(processes, indent=2, default=str))
    
    print("\n=== System Log Analysis ===")
    logs = analyzer.analyze_system_logs('/var/log')
    for category, items in logs.items():
        if items:
            print(f"\n{category.upper()}:")
            for item in items[:5]:  # Show first 5 items of each category
                print(f"- {item}")
