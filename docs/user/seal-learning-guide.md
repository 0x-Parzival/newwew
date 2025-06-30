# SEAL Learning System for Kalki OS

## Overview

The SEAL (Self-Adapting Language Models) learning system has been integrated into Kalki OS to provide continuous AI learning capabilities. This system allows the AI to learn from user interactions and continuously improve its responses over time.

## Features

- **Continuous Learning**: The AI learns from every user interaction
- **Knowledge Incorporation**: New knowledge is automatically incorporated into the AI's understanding
- **Few-Shot Adaptation**: The AI adapts based on examples and patterns
- **Background Processing**: Learning happens automatically in the background
- **Local Privacy**: All learning happens locally with your dolphin3/Ollama setup
- **Monitoring**: Real-time monitoring of learning progress and statistics

## Architecture

### Components

1. **SEAL Adapter** (`seal_adapter.py`)
   - Integrates SEAL framework with dolphin3/Ollama
   - Handles learning data extraction and storage
   - Manages adaptation triggers

2. **Enhanced LLM Agent** (`enhanced-llm-agent.py`)
   - Enhanced version of the existing LLM chat agent
   - Integrates learning capabilities into conversations
   - Provides learning statistics and controls

3. **SEAL Learning Daemon** (`seal_learning_daemon.py`)
   - Runs continuous learning processes in the background
   - Monitors learning progress and generates reports
   - Manages periodic adaptations

4. **Systemd Service** (`seal-learning-daemon.service`)
   - Automatically starts the learning daemon on boot
   - Provides system-level management

## Installation

### Prerequisites

- Python 3.7+
- Ollama with dolphin-mistral model
- Git
- Systemd

### Quick Setup

1. **Clone SEAL Repository**:
   ```bash
   git clone https://github.com/Continual-Intelligence/SEAL.git external/SEAL
   ```

2. **Install Python Dependencies**:
   ```bash
   pip3 install requests numpy scikit-learn pandas matplotlib seaborn torch transformers datasets accelerate
   ```

3. **Setup System Directories**:
   ```bash
   sudo mkdir -p /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki
   sudo chown -R kalki:kalki /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki
   ```

4. **Install Systemd Service**:
   ```bash
   sudo cp configs/systemd/seal-learning-daemon.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable seal-learning-daemon.service
   ```

5. **Start the Learning System**:
   ```bash
   sudo systemctl start seal-learning-daemon.service
   ```

## Usage

### Enhanced Chat Agent

The enhanced chat agent provides the same interface as the original LLM agent but with learning capabilities:

```bash
python3 src/ai-system/omnet-shell/enhanced-llm-agent.py
```

**Special Commands**:
- `stats` - Show learning statistics
- `adapt` - Trigger manual adaptation
- `export` - Export learning data
- `exit` - Quit the agent

### Learning Daemon Management

**Start the daemon**:
```bash
sudo systemctl start seal-learning-daemon.service
```

**Stop the daemon**:
```bash
sudo systemctl stop seal-learning-daemon.service
```

**Check status**:
```bash
sudo systemctl status seal-learning-daemon.service
```

**View logs**:
```bash
sudo journalctl -u seal-learning-daemon.service -f
```

### Manual Adaptation

Trigger manual adaptation:
```bash
python3 src/ai-system/omnet-shell/seal_learning_daemon.py adapt
```

### Learning Statistics

View learning statistics:
```bash
python3 src/ai-system/omnet-shell/seal_learning_daemon.py status
```

## Configuration

### Daemon Configuration

Edit the daemon configuration file:
```bash
sudo nano /etc/kalki/seal_daemon.conf
```

**Configuration Options**:
```json
{
    "adaptation_interval": 3600,        // Adaptation interval in seconds
    "learning_threshold": 10,           // Minimum interactions before adaptation
    "max_learning_data": 1000,          // Maximum learning data points to keep
    "enable_continuous_learning": true, // Enable continuous learning
    "enable_periodic_adaptation": true, // Enable periodic adaptation
    "ollama_health_check_interval": 300, // Health check interval in seconds
    "log_level": "INFO"                 // Logging level
}
```

### Learning Data Storage

Learning data is stored in:
- `/var/lib/kalki/seal_learning_data.jsonl` - Raw learning data
- `/var/lib/kalki/learning_report.json` - Learning statistics and reports
- `/var/log/kalki/seal_daemon.log` - Daemon logs

## How It Works

### Learning Process

1. **Interaction Capture**: Every user interaction is captured and stored
2. **Data Processing**: Interactions are processed to extract learning patterns
3. **Knowledge Incorporation**: New knowledge is incorporated into the AI's understanding
4. **Few-Shot Adaptation**: The AI adapts based on examples and patterns
5. **Continuous Improvement**: The AI continuously improves its responses

### Adaptation Triggers

Adaptation is triggered when:
- Sufficient learning data is collected (default: 10 interactions)
- Enough time has passed since last adaptation (default: 1 hour)
- Manual adaptation is requested

### Learning Types

1. **Knowledge Incorporation**:
   - Extracts key information from user interactions
   - Incorporates new knowledge into AI understanding
   - Updates response patterns

2. **Few-Shot Adaptation**:
   - Learns from examples and patterns
   - Adapts responses for similar future interactions
   - Improves task-specific capabilities

## Monitoring and Debugging

### Log Files

- `/var/log/kalki/seal_daemon.log` - Main daemon log
- `/var/log/kalki/seal_adapter.log` - SEAL adapter log
- `~/.config/omnet-shell/enhanced-llm-agent.log` - Enhanced agent log

### Health Checks

Check if Ollama is available:
```bash
curl http://localhost:11434/api/tags
```

Check learning system health:
```bash
python3 src/ai-system/omnet-shell/seal_learning_daemon.py status
```

### Troubleshooting

**Daemon not starting**:
```bash
sudo systemctl status seal-learning-daemon.service
sudo journalctl -u seal-learning-daemon.service -n 50
```

**Learning not working**:
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Check learning data
ls -la /var/lib/kalki/

# Check logs
tail -f /var/log/kalki/seal_daemon.log
```

**Permission issues**:
```bash
sudo chown -R kalki:kalki /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki
```

## Integration with Existing Systems

### Avatar System

The SEAL learning system integrates with the existing avatar system:
- Learning data is shared across avatars
- Each avatar can contribute to and benefit from learning
- Avatar-specific adaptations are preserved

### Terminal Integration

The enhanced LLM agent can be used as a drop-in replacement for the existing agent:
- Same interface and commands
- Additional learning capabilities
- Backward compatibility

### System Automation

The learning system integrates with system automation:
- Learns from automation patterns
- Improves automation suggestions
- Adapts to user preferences

## Privacy and Security

### Data Privacy

- All learning happens locally
- No data is sent to external servers
- Learning data is stored in protected directories
- User can export and delete learning data

### Security Features

- Process isolation with systemd
- Limited file system access
- Resource limits and monitoring
- Secure logging and error handling

## Performance Considerations

### Resource Usage

- Memory: ~512MB maximum
- CPU: ~50% maximum
- Disk: Learning data grows over time (managed automatically)

### Optimization

- Learning data is automatically cleaned up
- Old data is archived or removed
- Adaptation frequency can be adjusted
- Resource limits can be configured

## Future Enhancements

### Planned Features

- Multi-model learning support
- Advanced adaptation algorithms
- Learning visualization tools
- Integration with more AI frameworks
- Cloud backup and sync capabilities

### Customization

- Custom learning algorithms
- Domain-specific adaptations
- Personalized learning paths
- Advanced monitoring and analytics

## Support and Community

### Getting Help

- Check the troubleshooting section
- Review log files for errors
- Consult the SEAL framework documentation
- Join the Kalki OS community

### Contributing

- Report bugs and issues
- Suggest improvements
- Contribute code and documentation
- Share learning experiences

## Conclusion

The SEAL learning system provides Kalki OS with powerful continuous learning capabilities while maintaining privacy and security. The system is designed to be easy to use, highly configurable, and deeply integrated with the existing Kalki OS ecosystem.

By enabling continuous learning, users can experience an AI that becomes more helpful and personalized over time, adapting to their specific needs and preferences while maintaining the security and privacy that Kalki OS is known for. 