# Granite Docling Demo - AI Coding Instructions

## Project Overview

This is a **Gradio-based HuggingFace Spaces demo** for IBM's Granite Docling 258M model (`ibm-granite/granite-docling-258M`). The app showcases document conversion capabilities including text extraction, table recognition, formula conversion to LaTeX, and multilingual document processing.

## Architecture & Key Components

### Main Application (`src/app.py`)
- **Gradio app** with custom IBM Research theming (`themes/research_monochrome.py`)
- **Model Integration**: Uses `Idefics3ForConditionalGeneration` with `@spaces.GPU()` decorator for HuggingFace Spaces GPU acceleration
- **Image Processing Pipeline**: Handles document images → model inference → bounding box visualization → optional Docling conversion
- **Sample Data Structure**: 9 predefined samples in `sample_data[]` with different document types (tables, formulas, multilingual docs)

### Critical Data Flow
1. **Image Selection**: Gallery → loads sample with predefined prompts OR user uploads custom image
2. **Inference**: User query + image → Granite model → streaming response with location tags `<loc_X>` 
3. **Post-Processing**: 
   - Extract location tags for bounding box visualization
   - Convert DocTags format to Docling markdown using `DocTagsDocument` and `DoclingDocument`
   - Special handling for LaTeX formula wrapping in `\begin{aligned}`

### Key Dependencies & Constraints
- **Python 3.10** (strict requirement - see `pyproject.toml`)
- **Poetry** for dependency management (NOT pip)
- **HuggingFace Spaces** deployment with `spaces` library and GPU decorators
- **Docling Core** (`docling_core`) for document structure conversion

## Development Workflows

### Essential Commands
```bash
# Setup (first time)
make setup-full                    # Complete new developer setup
poetry shell                      # Activate environment 

# Daily development  
make dev-server                   # Start with hot reload: `gradio src/app.py`
make test-all                     # Lint, format, syntax, imports, app loading
make lint-fix                     # Auto-fix linting issues

# Deployment preparation
make deploy-prep                  # Runs all checks + builds requirements.txt
make build-requirements           # Export poetry.lock → requirements.txt
```

### Pre-commit Hooks (CRITICAL)
- **Mandatory** - all commits must pass pre-commit checks
- Includes: Ruff linting, Black formatting, conventional commits (gitlint)
- Install: `pre-commit install` (done by `make setup-full`)

## Project-Specific Patterns

### Model Loading Pattern
```python
# Only load model when not in reload mode (performance)
if gr.NO_RELOAD:
    processor = AutoProcessor.from_pretrained(model_id, use_auth_token=True)
    model = Idefics3ForConditionalGeneration.from_pretrained(...)
```

### Streaming Response Pattern
- Uses `TextIteratorStreamer` for real-time token generation
- HTML escaping during streaming, unescape for final processing
- Global variable `_streaming_raw_output` captures final result

### Location Tag Processing
- Model outputs location tags: `<class><loc_X><loc_Y><loc_W><loc_H>` (normalized to 500x500 grid)
- `draw_bounding_boxes()` converts to actual image coordinates and draws colored rectangles
- Different colors for different document elements (tables, text, formulas, etc.)

### Theme Integration
- Custom IBM Research monochrome theme in `src/themes/`
- **DO NOT modify** - maintains consistency with IBM demo standards
- CSS customizations in `src/app.css` for animations and gallery effects

## File Structure Conventions

```
src/
├── app.py              # Main Gradio application
├── app.css             # Custom styling (jumping dots animation, gallery hover)
├── app_head.html       # Google Analytics tracking
└── themes/             # IBM theme files (DO NOT MODIFY)
data/images/            # Sample document images (PNG/JPG format)
```

## Configuration & Deployment

### HuggingFace Spaces Config (`README.md` header)
- `app_file: src/app.py` - entry point
- `python_version: 3.10` - strict requirement
- `sdk_version: 5.16.1` - Gradio version (update carefully)

### Environment Variables
- `HUGGINGFACE_API_TOKEN` - for model access (stored in `.env` - DO NOT COMMIT)
- `NO_LLM` - development flag to simulate model responses

### Quality Standards
- **Line length**: 120 characters (Ruff + Black config)
- **Import organization**: isort with black profile
- **Documentation**: Google-style docstrings
- **Conventional commits**: Required by gitlint

## Common Gotchas

1. **Poetry vs Pip**: Always use Poetry (`poetry add package`) - `requirements.txt` is auto-generated
2. **GPU Decorators**: Use `@spaces.GPU()` for model inference functions only
3. **Image Padding**: Some samples use `add_random_padding()` - check `sample_data[].pad` flag
4. **Model Auth**: Requires valid HuggingFace token for `ibm-granite` model access
5. **Deployment**: Only `stable` branch deploys to production - `main` goes to QA environment
