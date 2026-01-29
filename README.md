# Audio Transcription MCP

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com/)

MCP (Model Context Protocol) server for audio transcription with speaker diarization. Transcribes MP3/WAV files using **Faster-Whisper** and **pyannote.audio**, outputting markdown with speaker labels, timestamps, summaries, and action items.

## ✨ Features

- 🎤 **Speaker Diarization** - Identifies and labels different speakers (Speaker 1, Speaker 2, etc.)
- 📝 **Markdown Output** - Clean, formatted transcripts with timestamps
- 🐳 **Docker Ready** - CPU and GPU containers for easy deployment
- 🚀 **MCP Protocol** - Integrates with GitHub Copilot CLI and other MCP clients
- 🔒 **Offline Capable** - Models cached locally after first run
- ⚡ **GPU Acceleration** - NVIDIA CUDA support for faster processing

## 📋 Requirements

### Prerequisites

- **Python 3.11+** (for local development)
- **Docker** (recommended for deployment)
- **Hugging Face Account** (free, for model access)
- **NVIDIA GPU + CUDA 12.3** (optional, for GPU acceleration)

### Hugging Face Setup (Required)

1. Create a free account at [huggingface.co](https://huggingface.co)
2. Accept model terms:
   - [pyannote/speaker-diarization-3.1](https://huggingface.co/pyannote/speaker-diarization-3.1)
   - [pyannote/segmentation-3.0](https://huggingface.co/pyannote/segmentation-3.0)
3. Generate a token at [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)

## 🚀 Quick Start

### Option 1: Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/ebmarquez/audio-transcription-mcp.git
cd audio-transcription-mcp

# Create .env file with your HF token
echo "HF_TOKEN=hf_your_token_here" > .env

# Build and run with Docker Compose
cd docker
docker compose up -d

# Container is now running at http://localhost:8080/mcp
```

### Option 2: Docker Run (One-Shot)

```bash
# CPU version
docker run --rm \
  -e HF_TOKEN="hf_your_token" \
  -v $(pwd)/input:/input:ro \
  -v $(pwd)/output:/output \
  -v $(pwd)/models:/root/.cache \
  -p 8080:8080 \
  audio-transcription-mcp:cpu

# GPU version (NVIDIA)
docker run --rm --gpus all \
  -e HF_TOKEN="hf_your_token" \
  -v $(pwd)/input:/input:ro \
  -v $(pwd)/output:/output \
  -v $(pwd)/models:/root/.cache \
  -p 8080:8080 \
  audio-transcription-mcp:gpu
```

### Option 3: Local Development

```bash
# Clone and install
git clone https://github.com/ebmarquez/audio-transcription-mcp.git
cd audio-transcription-mcp
pip install -e .

# Set up environment
cp .env.example .env
# Edit .env and add your HF_TOKEN

# Run MCP server
python -m audio_transcription_mcp
```

## 🔧 MCP Client Configuration

### GitHub Copilot CLI (Docker Mode)

Add to your `mcp.json`:

```json
{
  "mcpServers": {
    "audio-transcription": {
      "url": "http://localhost:8080/mcp",
      "transport": "streamable-http"
    }
  }
}
```

### GitHub Copilot CLI (Local Mode)

```json
{
  "mcpServers": {
    "audio-transcription": {
      "command": "python",
      "args": ["-m", "audio_transcription_mcp"],
      "env": {
        "HF_TOKEN": "${HF_TOKEN}",
        "OUTPUT_DIR": "./transcriptions"
      }
    }
  }
}
```

## 🛠️ MCP Tools

### `transcribe_audio`

Transcribe a single audio file with speaker diarization.

```python
transcribe_audio(
    file_path="/input/meeting.mp3",
    output_dir="/output",
    model_size="large-v3",
    include_timestamps=True,
    generate_summary=True
)
```

### `transcribe_directory`

Batch transcribe all audio files in a directory.

```python
transcribe_directory(
    directory_path="/input",
    output_dir="/output",
    recursive=False
)
```

### `get_transcription_status`

Check if an audio file has been transcribed.

```python
get_transcription_status(file_path="/input/meeting.mp3")
```

## 📄 Output Format

Transcriptions are saved as markdown files:

```markdown
# Audio Transcription: meeting-recording.mp3

## Metadata
- **Source File**: meeting-recording.mp3
- **Duration**: 45:32
- **Speakers Detected**: 3
- **Transcription Date**: 2026-01-29
- **Model**: faster-whisper large-v3

---

## Transcript

### [00:00:00] **Speaker 1**
Good morning everyone. Let's get started with our weekly sync.

### [00:00:05] **Speaker 2**
Thanks for organizing this. I have a few updates on the project.

...

---

## Summary
[AI-generated summary placeholder]

## Key Points
- Point 1 extracted from conversation
- Point 2 extracted from conversation

## Action Items
- [ ] Action item 1 - Assigned to: Speaker 1
- [ ] Action item 2 - Assigned to: Speaker 2
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `HF_TOKEN` | Hugging Face token (required) | - |
| `WHISPER_MODEL` | Model size: tiny/base/small/medium/large-v3 | `large-v3` |
| `LANGUAGE` | Transcription language (ISO 639-1) | `en` |
| `MAX_FILE_SIZE_GB` | Maximum file size in GB | `1` |
| `INPUT_DIR` | Input directory for audio files | `./input` |
| `OUTPUT_DIR` | Output directory for transcriptions | `./output` |
| `MCP_TRANSPORT` | Transport mode: stdio/streamable-http | `streamable-http` |
| `MCP_PORT` | HTTP port (for streamable-http) | `8080` |
| `CUDA_VISIBLE_DEVICES` | GPU device ID (-1 for CPU) | `0` |

### Model Size Comparison

| Model | Accuracy | Speed | Memory |
|-------|----------|-------|--------|
| `tiny` | ⭐ | Fastest | ~1GB |
| `base` | ⭐⭐ | Fast | ~1GB |
| `small` | ⭐⭐⭐ | Moderate | ~2GB |
| `medium` | ⭐⭐⭐⭐ | Slow | ~5GB |
| `large-v3` | ⭐⭐⭐⭐⭐ | Slowest | ~10GB |

## 📁 Project Structure

```
audio-transcription-mcp/
├── docker/
│   ├── Dockerfile.cpu          # CPU container
│   ├── Dockerfile.gpu          # GPU container (NVIDIA)
│   ├── docker-compose.yml      # Development compose
│   ├── docker-compose.prod.yml # Production compose
│   └── entrypoint.sh           # Container startup
├── src/
│   └── audio_transcription_mcp/
│       ├── __init__.py
│       ├── __main__.py         # Entry point
│       ├── server.py           # MCP server
│       ├── config.py           # Configuration
│       ├── audio_processor.py  # File handling
│       ├── transcriber.py      # Faster-Whisper
│       ├── diarizer.py         # pyannote.audio
│       ├── segment_merger.py   # Align segments
│       └── markdown_generator.py
├── tests/
├── input/                      # Audio files (mount point)
├── output/                     # Transcriptions (mount point)
├── models/                     # Model cache (mount point)
├── .env.example
├── pyproject.toml
└── requirements.txt
```

## 🐳 Docker Volumes

| Mount Point | Purpose | Mode |
|-------------|---------|------|
| `/input` | Audio files to transcribe | Read-only |
| `/output` | Transcription results | Read-write |
| `/root/.cache` | Model cache (persistent) | Read-write |

## ⚠️ Known Limitations

- **Speaker Diarization**: Works best with 2-6 distinct speakers
- **Audio Quality**: May struggle with background noise, overlapping speech, or phone/video call audio
- **Large Files**: Files over 30 minutes may take significant processing time
- **First Run**: Initial model download requires internet connection (~3GB)

## 🔒 Security

- **HF_TOKEN**: Store securely, never commit to repository
- **Input Validation**: Strict file type and size validation
- **Path Traversal**: All file paths are sanitized
- **Container Isolation**: Runs with minimal privileges

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- [Faster-Whisper](https://github.com/SYSTRAN/faster-whisper) - Fast Whisper implementation
- [pyannote.audio](https://github.com/pyannote/pyannote-audio) - Speaker diarization
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification
MCP server for audio transcription with speaker diarization. Transcribes MP3/WAV files using Faster-Whisper and pyannote.audio, outputs markdown with speaker labels, timestamps, summaries, and action items. Dockerized for easy deployment (CPU/GPU).
