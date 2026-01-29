#!/bin/bash
# Audio Transcription MCP - Container Entrypoint
set -e

# =============================================================================
# Validate Required Environment Variables
# =============================================================================
if [ -z "$HF_TOKEN" ]; then
    echo "=============================================="
    echo "ERROR: HF_TOKEN environment variable is required"
    echo "=============================================="
    echo ""
    echo "To get your Hugging Face token:"
    echo "1. Create account at: https://huggingface.co"
    echo "2. Accept model terms at:"
    echo "   - https://huggingface.co/pyannote/speaker-diarization-3.1"
    echo "   - https://huggingface.co/pyannote/segmentation-3.0"
    echo "3. Generate token at: https://huggingface.co/settings/tokens"
    echo "4. Set HF_TOKEN environment variable"
    echo ""
    echo "Example:"
    echo "  docker run -e HF_TOKEN=hf_xxxxx ..."
    echo ""
    exit 1
fi

# =============================================================================
# Log Startup Information
# =============================================================================
echo "========================================================"
echo "  Audio Transcription MCP Server"
echo "========================================================"
echo ""
echo "  Configuration:"
echo "  --------------"
echo "  Whisper Model:   ${WHISPER_MODEL:-large-v3}"
echo "  Language:        ${LANGUAGE:-en}"
echo "  Max File Size:   ${MAX_FILE_SIZE_GB:-1} GB"
echo "  Input Directory: ${INPUT_DIR:-/input}"
echo "  Output Directory:${OUTPUT_DIR:-/output}"
echo ""
echo "  Server:"
echo "  -------"
echo "  Transport:       ${MCP_TRANSPORT:-streamable-http}"
echo "  Port:            ${MCP_PORT:-8080}"
echo ""

# Check for GPU
if command -v nvidia-smi &> /dev/null; then
    echo "  GPU:"
    echo "  ----"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || echo "  GPU detected but nvidia-smi failed"
    echo ""
fi

echo "========================================================"
echo ""
echo "Starting MCP server..."
echo ""

# =============================================================================
# Start MCP Server
# =============================================================================
exec python -m audio_transcription_mcp \
    --transport "${MCP_TRANSPORT:-streamable-http}" \
    --port "${MCP_PORT:-8080}"
