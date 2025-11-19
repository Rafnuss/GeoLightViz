# GeoLightViz App Architecture# GeoLightViz App Architecture & Structure# GeoLightViz Architecture Diagram



> A guide to understanding the modular structure of the GeoLightViz Shiny application



---This document describes the modular architecture of the GeoLightViz Shiny application, including file organization, data flow, module interactions, and usage guidelines.## File Organization



## Overview



The GeoLightViz app has been refactored from a single 720-line `server.R` file into a modular structure with:## Table of Contents```

- **Main server**: 50 lines (93% reduction!)

- **Feature modules**: 9 files averaging 67 lines each1. [File Organization](#file-organization)inst/app/

- **Clear separation**: Each file handles one specific feature

2. [Code Metrics](#code-metrics)│

---

3. [Data Flow](#data-flow)├── global.R                        # Load packages & source all modules

## File Structure

4. [Module Interactions](#module-interactions)├── ui.R                            # User interface

```

inst/app/5. [Reactive Dependencies](#reactive-dependencies)├── server_new.R (50 lines)         # Orchestrates all modules

├── global.R                # Load packages and data

├── ui.R                    # User interface6. [Observer Triggers](#observer-triggers)│

├── server.R                # Main server (50 lines)

│7. [Server Modules](#server-modules)├── modules/                        # Reusable Shiny modules

├── modules/                # Reusable components

│   ├── utils.R            # Time conversion helpers8. [Reusable Modules](#reusable-modules)│   ├── utils.R                     # Helper functions (time conversions)

│   └── modal_calibration.R # Calibration modal

│9. [Usage Guide](#usage-guide)│   ├── modal_calibration.R         # Calibration modal (200 lines)

└── server/                 # Feature-specific logic

    ├── reactive_values.R       # Initialize reactive data10. [Key Design Patterns](#key-design-patterns)│   └── map_module.R                # Map module template

    ├── map_functions.R         # Map calculations

    ├── plotly_output.R         # Light plot visualization11. [Testing Strategy](#testing-strategy)│

    ├── map_output.R            # Leaflet map rendering

    ├── navigation_observers.R  # Prev/next buttons12. [Migration Path](#migration-path)└── server/                         # Server logic by feature

    ├── drawing_observers.R     # Add/edit staps

    ├── labeling_observers.R    # Label twilights13. [Benefits](#benefits-of-modular-structure)    ├── reactive_values.R    (40)   # Config & reactive initialization

    ├── position_observers.R    # Position editing

    └── export_handlers.R       # Download data    ├── map_functions.R      (95)   # Map likelihood & display reactives

```

---    ├── plotly_output.R      (110)  # Main light-level plot

---

    ├── map_output.R         (110)  # Leaflet map rendering

## How It Works

## File Organization    ├── navigation_observers.R (50) # Previous/next navigation

### 1. User Interactions → Observers

    ├── drawing_observers.R   (95)  # Add/remove/edit staps

```

Click "Next" button      → navigation_observers.R → Change stap```    ├── labeling_observers.R  (90)  # Label twilight points

Draw rectangle on plot   → drawing_observers.R    → Create/modify stap

Click twilight point     → labeling_observers.R   → Toggle labelinst/app/    ├── position_observers.R  (50)  # ML & manual position editing

Click "ML Position"      → position_observers.R   → Find best location

Click "Export"           → export_handlers.R      → Download CSV│    └── export_handlers.R     (25)  # Download twilight/stap data

```

├── global.R                        # Load packages & source all modules```

### 2. Data Flow

├── ui.R                            # User interface definition

```

User Input → Reactive Values → Render Outputs├── server.R                        # Original monolithic server (reference)## Data Flow

            (twl, stapath)     (plotly, map)

```├── server_new.R (50 lines)         # New modular server (recommended)



**Key reactive values:**│```

- `twl()`: Twilight data with labels

- `stapath()`: Stationary periods with positions├── modules/                        # Reusable Shiny modules┌─────────────────────────────────────────────────────────────────┐



**Main outputs:**│   ├── README.md                   # Module documentation│                         global.R                                 │

- `output$plotly_div`: Interactive light plot

- `output$map`: Geographic likelihood map│   ├── utils.R                     # Helper functions (time conversions)│  • Load packages (shiny, GeoPressureR, etc.)                    │



---│   ├── modal_calibration.R (200)   # Calibration modal module│  • Source all modules and server files                          │



## Key Files Explained│   └── map_module.R                # Map module template│  • Load initial data (.twl, .stapath, .g, .pgz, etc.)          │



### Core Files│└─────────────────────────────────────────────────────────────────┘



**`server.R`** - Orchestrates everything└── server/                         # Server logic by feature                                ↓

- Initializes reactive values

- Sets up all observers    ├── reactive_values.R    (40)   # Config & reactive initialization┌─────────────────────────────────────────────────────────────────┐

- Connects modules together

    ├── map_functions.R      (95)   # Map likelihood & display reactives│                       server_new.R                               │

**`global.R`** - Startup

- Loads packages (shiny, GeoPressureR, plotly, leaflet)    ├── plotly_output.R      (110)  # Main light-level plot├─────────────────────────────────────────────────────────────────┤

- Sources all module files

- Loads initial data    ├── map_output.R         (110)  # Leaflet map rendering│  1. init_reactive_values()          → twl, stapath, drawing    │



**`ui.R`** - User interface    ├── navigation_observers.R (50) # Previous/next navigation│  2. get_known_positions()            → known_positions          │

- Layout with plotly plot (left) and map (right)

- Navigation and editing buttons    ├── drawing_observers.R   (95)  # Add/remove/edit staps│  3. init_map_reactives()             → map_likelihood, display  │

- Export controls

    ├── labeling_observers.R  (90)  # Label twilight points│  4. modal_calibration_server()       → show_calibration()       │

### Feature Modules

    ├── position_observers.R  (50)  # ML & manual position editing│  5. setup_navigation_observers()     → update_stapath()         │

**`plotly_output.R`** - Light level visualization

- Displays heatmap of light measurements    └── export_handlers.R     (25)  # Download twilight/stap data│  6. render_plotly_output()           → output$plotly_div        │

- Shows twilight points (yellow = keep, red = discard)

- Overlays predicted twilight lines```│  7. render_map_output()              → output$map               │

- Handles zoom/draw/select modes

│  8. setup_drawing_observers()        → add/remove/edit staps    │

**`map_output.R`** - Geographic display

- Renders likelihood heatmap---│  9. setup_labeling_observers()       → label twilights          │

- Shows current position and path

- Displays known calibration locations│ 10. setup_position_observers()       → ML/manual position       │



**`navigation_observers.R`** - Moving between staps## Code Metrics│ 11. setup_export_handlers()          → download handlers        │

- Previous/next button handlers

- Updates the stap selector└─────────────────────────────────────────────────────────────────┘

- Opens calibration modal

- **Original server.R**: ~720 lines                                ↓

**`drawing_observers.R`** - Creating/editing staps

- Enables rectangle drawing mode- **New server_new.R**: ~50 lines (93% reduction)┌─────────────────────────────────────────────────────────────────┐

- Creates new stationary periods

- Modifies existing time ranges- **Total server/ files**: ~600 lines across 9 files (avg 67 lines each)│                         ui.R                                     │

- Auto-calculates ML positions

- **Reduction in complexity**: >90% smaller main file├─────────────────────────────────────────────────────────────────┤

**`labeling_observers.R`** - Twilight quality control

- Click individual points to toggle labels│  • Header with tag ID and controls                              │

- Draw selection boxes for batch labeling

- Preserves zoom state---│  • Navigation (previous/next/histogram buttons)                 │



**`position_observers.R`** - Geographic positioning│  • Stap management (add/remove/change range)                    │

- Finds maximum likelihood position

- Enables manual position editing## Data Flow│  • Main layout:                                                  │

- Updates position from map clicks

│    ├── Plotly plot (7 columns)                                  │

**`export_handlers.R`** - Data export

- Downloads labeled twilight CSV```│    └── Leaflet map (5 columns)                                  │

- Downloads stap table CSV

┌─────────────────────────────────────────────────────────────────┐│  • Export buttons (twilight, stap)                              │

### Supporting Modules

│                         global.R                                 │└─────────────────────────────────────────────────────────────────┘

**`reactive_values.R`**

- Creates all reactive values│  • Load packages (shiny, GeoPressureR, etc.)                    │```

- Sets configuration (colors, thresholds)

- Extracts known positions from initial data│  • Source all modules and server files                          │



**`map_functions.R`**│  • Load initial data (.twl, .stapath, .g, .pgz, etc.)          │## Module Interactions

- Calculates likelihood maps

- Projects coordinates (lat/lon ↔ Web Mercator)└─────────────────────────────────────────────────────────────────┘

- Filters by probability threshold

                                ↓```

**`modal_calibration.R`**

- Shows twilight error histogram┌─────────────────────────────────────────────────────────────────┐┌─────────────────┐

- Validates calibration quality

- Compares observed vs predicted twilights│                       server_new.R                               ││  User Actions   │



**`utils.R`**├─────────────────────────────────────────────────────────────────┤└────────┬────────┘

- `time2plottime()`: Converts datetime to plot coordinates

- `datetime2floathour()`: Time to decimal hours│  1. init_reactive_values()          → twl, stapath, drawing    │         │



---│  2. get_known_positions()            → known_positions          │         ├─► Navigation buttons ──────► navigation_observers.R



## Design Principles│  3. init_map_reactives()             → map_likelihood, display  │         │                               └─► update_stapath()



### 1. Separation of Concerns│  4. modal_calibration_server()       → show_calibration()       │         │

Each file has one job. Need to fix navigation? Look in `navigation_observers.R`.

│  5. setup_navigation_observers()     → update_stapath()         │         ├─► Histogram button ──────────► modal_calibration.R

### 2. Functional Approach

Functions receive inputs and return outputs—no hidden dependencies.│  6. render_plotly_output()           → output$plotly_div        │         │                               └─► show modal with plotly



### 3. Dependency Injection│  7. render_map_output()              → output$map               │         │

```r

# Bad: Function looks for global variables│  8. setup_drawing_observers()        → add/remove/edit staps    │         ├─► Label twilight ────────────► labeling_observers.R

render_plot <- function() {

  data <- twl  # Where does 'twl' come from?│  9. setup_labeling_observers()       → label twilights          │         │   (click/select)               ├─► update twl() labels

}

│ 10. setup_position_observers()       → ML/manual position       │         │                               └─► re-render plotly

# Good: Function receives what it needs

render_plot <- function(twl) {│ 11. setup_export_handlers()          → download handlers        │         │

  data <- twl  # Clear dependency

}└─────────────────────────────────────────────────────────────────┘         ├─► Draw rectangle ────────────► drawing_observers.R

```

                                ↓         │   (add/change stap)            ├─► create/modify stap

### 4. Reusable Components

Modules can be used in other apps or tested independently.┌─────────────────────────────────────────────────────────────────┐         │                               └─► update_stapath()



---│                         ui.R                                     │         │



## Making Changes├─────────────────────────────────────────────────────────────────┤         ├─► ML/Edit position ──────────► position_observers.R



### To modify a feature:│  • Header with tag ID and controls                              │         │                               ├─► calc ML or use click

1. **Find the right file** using the structure above

2. **Edit the specific function** handling that feature│  • Navigation (previous/next/histogram buttons)                 │         │                               └─► update stapath() coords

3. **Test in isolation** if possible

│  • Stap management (add/remove/change range)                    │         │

### To add a new feature:

1. **Create a new file** in `server/` (e.g., `filter_observers.R`)│  • Main layout:                                                  │         └─► Export buttons ────────────► export_handlers.R

2. **Write setup function** (e.g., `setup_filter_observers()`)

3. **Source it** in `global.R`│    ├── Plotly plot (7 columns)                                  │                                         └─► generate CSV files

4. **Call it** in `server.R`

│    └── Leaflet map (5 columns)                                  │```

### Example: Adding a filter button

│  • Export buttons (twilight, stap)                              │

**1. Create `server/filter_observers.R`:**

```r└─────────────────────────────────────────────────────────────────┘## Reactive Dependencies

setup_filter_observers <- function(input, twl) {

  observeEvent(input$filter_button, {```

    twl_data <- twl()

    # Filter logic here```

    twl(filtered_data)

  })---                    ┌──────────┐

}

```                    │   twl    │ ← labeling_observers



**2. Add to `global.R`:**## Module Interactions                    └─────┬────┘

```r

source("server/filter_observers.R")                          │

```

```            ┌─────────────┼─────────────┐

**3. Call in `server.R`:**

```r┌─────────────────┐            │             │             │

setup_filter_observers(input, twl)

```│  User Actions   │            ↓             ↓             ↓



---└────────┬────────┘    ┌──────────────┐  ┌──────────┐  ┌──────────────┐



## Testing         │    │ plotly_div   │  │ map_like-│  │ export_twl   │



### Unit Tests         ├─► Navigation buttons ──────► navigation_observers.R    │ (render)     │  │ lihood   │  │ (download)   │

Test individual functions:

```r         │                               └─► update_stapath()    └──────────────┘  └─────┬────┘  └──────────────┘

test_that("time conversion works", {

  result <- time2plottime(datetime)         │                            │

  expect_equal(result, expected_value)

})         ├─► Histogram button ──────────► modal_calibration.R                            ↓

```

         │                               └─► show modal with plotly                      ┌──────────┐

### Integration Tests

Test user workflows with `shinytest2`:         │                      │   map    │

```r

app$set_inputs(next_position = "click")         ├─► Label twilight ────────────► labeling_observers.R                      │ (render) │

app$expect_values()

```         │   (click/select)               ├─► update twl() labels                      └──────────┘



---         │                               └─► re-render plotly



## Migration Status         │                    ┌──────────┐



✅ **Phase 1** (Current): Both `server.R` and `server_new.R` exist           ├─► Draw rectangle ────────────► drawing_observers.R                    │ stapath  │ ← drawing_observers

⏳ **Phase 2**: Rename `server_new.R` → `server.R`  

📋 **Phase 3**: Add comprehensive tests         │   (add/change stap)            ├─► create/modify stap                    └─────┬────┘   ← position_observers



---         │                               └─► update_stapath()                          │



## Benefits         │            ┌─────────────┼─────────────┐



| Before | After |         ├─► ML/Edit position ──────────► position_observers.R            │             │             │

|--------|-------|

| 720-line server file | 50-line orchestrator |         │                               ├─► calc ML or use click            ↓             ↓             ↓

| Hard to find code | Organized by feature |

| Difficult to test | Testable functions |         │                               └─► update stapath() coords    ┌──────────────┐  ┌──────────┐  ┌──────────────┐

| Risky changes | Isolated modifications |

| Poor collaboration | Clear ownership |         │    │ plotly_div   │  │ map      │  │ export_stap  │



---         └─► Export buttons ────────────► export_handlers.R    │ (update)     │  │ (markers)│  │ (download)   │



## Quick Reference                                         └─► generate CSV files    └──────────────┘  └──────────┘  └──────────────┘



**Need to modify...** | **Edit this file**``````

---|---

Light plot appearance | `plotly_output.R`

Map display | `map_output.R`

Next/Previous behavior | `navigation_observers.R`---## Observer Triggers

Stap creation | `drawing_observers.R`

Twilight labeling | `labeling_observers.R`

Position calculation | `position_observers.R`

Data export | `export_handlers.R`## Reactive Dependencies```

Initial setup | `reactive_values.R`

Map calculations | `map_functions.R`Input Events                    Observer Module              Action

Calibration modal | `modal_calibration.R`

```─────────────────────────────────────────────────────────────────────

---

                    ┌──────────┐input$previous_position      → navigation_observers    → Change stap_id

## Questions?

                    │   twl    │ ← labeling_observersinput$next_position          → navigation_observers    → Change stap_id

- **Package docs**: `?geolightviz`

- **GeoPressureR**: https://raphaelnussbaumer.com/GeoPressureR/                    └─────┬────┘input$show_twilight_histogram→ navigation_observers    → Show modal

- **Issues**: https://github.com/Rafnuss/GeoLightViz/issues

                          │input$add_stap               → drawing_observers       → Enable drawing

            ┌─────────────┼─────────────┐input$remove_stap            → drawing_observers       → Delete current

            │             │             │input$change_range           → drawing_observers       → Enable drawing

            ↓             ↓             ↓plotly_relayout (rectangle)  → drawing_observers       → Create/modify stap

    ┌──────────────┐  ┌──────────┐  ┌──────────────┐input$label_twilight         → labeling_observers      → Toggle mode

    │ plotly_div   │  │ map_like-│  │ export_twl   │plotly_click                 → labeling_observers      → Toggle nearby labels

    │ (render)     │  │ lihood   │  │ (download)   │plotly_selected              → labeling_observers      → Toggle selected labels

    └──────────────┘  └─────┬────┘  └──────────────┘plotly_relayout (zoom/pan)   → labeling_observers      → Save zoom state

                            │input$ml_position            → position_observers      → Find ML coords

                            ↓input$edit_position          → position_observers      → Toggle edit mode

                      ┌──────────┐input$map_click              → position_observers      → Set clicked coords

                      │   map    │input$map_style              → map_output              → Switch raster/contour

                      │ (render) │```

                      └──────────┘

## Key Design Patterns

                    ┌──────────┐

                    │ stapath  │ ← drawing_observers1. **Separation of Concerns**: Each file handles one specific feature

                    └─────┬────┘   ← position_observers2. **Functional Programming**: Most modules export functions, not objects

                          │3. **Dependency Injection**: Functions receive their dependencies as parameters

            ┌─────────────┼─────────────┐4. **Return Values**: Setup functions return helper functions for cross-module use

            │             │             │5. **list2env Pattern**: Unpack lists into environment for cleaner code

            ↓             ↓             ↓6. **Observer Pattern**: All user interactions trigger observers

    ┌──────────────┐  ┌──────────┐  ┌──────────────┐7. **Reactive Programming**: Data flows through reactive values

    │ plotly_div   │  │ map      │  │ export_stap  │

    │ (update)     │  │ (markers)│  │ (download)   │## Testing Strategy

    └──────────────┘  └──────────┘  └──────────────┘

``````

Unit Tests (R package structure)

---├── test-utils.R              # Test time conversion functions

├── test-reactive_values.R    # Test initialization

## Observer Triggers├── test-map_functions.R      # Test likelihood calculations

└── test-modal_calibration.R  # Test calibration logic

```

Input Events                    Observer Module              ActionIntegration Tests (shinytest2)

─────────────────────────────────────────────────────────────────────├── test-navigation.R         # Test prev/next buttons

input$previous_position      → navigation_observers    → Change stap_id├── test-labeling.R           # Test twilight labeling workflow

input$next_position          → navigation_observers    → Change stap_id├── test-drawing.R            # Test stap add/remove/edit

input$show_twilight_histogram→ navigation_observers    → Show modal└── test-export.R             # Test download handlers

input$add_stap               → drawing_observers       → Enable drawing```

input$remove_stap            → drawing_observers       → Delete current
input$change_range           → drawing_observers       → Enable drawing
plotly_relayout (rectangle)  → drawing_observers       → Create/modify stap
input$label_twilight         → labeling_observers      → Toggle mode
plotly_click                 → labeling_observers      → Toggle nearby labels
plotly_selected              → labeling_observers      → Toggle selected labels
plotly_relayout (zoom/pan)   → labeling_observers      → Save zoom state
input$ml_position            → position_observers      → Find ML coords
input$edit_position          → position_observers      → Toggle edit mode
input$map_click              → position_observers      → Set clicked coords
input$map_style              → map_output              → Switch raster/contour
```

---

## Server Modules

Each server module is responsible for a specific feature area:

### `server/reactive_values.R`
**Purpose**: Initialize reactive values and configuration
- `init_reactive_values()`: Creates all reactive values (twl, stapath, drawing states, etc.)
- `get_known_positions()`: Extracts known positions from initial stapath
- Configuration parameters (colors, thresholds)

### `server/map_functions.R`
**Purpose**: Map-related reactive expressions and calculations
- `init_map_reactives()`: Creates map likelihood, display, and contour reactives
- Projection calculations for EPSG:3857
- Likelihood calculation with threshold filtering
- Returns: `map_likelihood`, `map_display`, `contour_display`, `map_likelihood_fx`

### `server/plotly_output.R`
**Purpose**: Main plotly visualization
- `render_plotly_output()`: Renders the interactive light-level plot
- Features:
  - Heatmap of light data
  - Highlighted current stap range
  - Twilight markers (valid/discarded)
  - Predicted twilight lines
  - Dynamic drag modes (zoom/draw/select)
  - Zoom state preservation

### `server/map_output.R`
**Purpose**: Leaflet map rendering and updates
- `render_map_output()`: Initial map setup with tile layers
- Observer for dynamic map updates
- Features:
  - Raster or contour display
  - Known positions overlay
  - Current stapath with circles and lines
  - Interactive controls

### `server/navigation_observers.R`
**Purpose**: Navigation and stap selection
- `setup_navigation_observers()`: Handles previous/next buttons
- `update_stapath_helper()`: Updates the stap selectInput
- Calibration modal trigger
- Tag ID rendering
- Returns: `update_stapath()` function for use by other modules

### `server/drawing_observers.R`
**Purpose**: Drawing rectangles and stap management
- `create_draw_range_function()`: Toggle drawing mode
- `setup_drawing_observers()`: Handles:
  - Add stap (draw new rectangle)
  - Remove stap (delete current)
  - Change range (modify existing)
  - Plotly relayout events (rectangle completion)
- Automatic ML position assignment for new staps

### `server/labeling_observers.R`
**Purpose**: Twilight point labeling
- `setup_labeling_observers()`: Handles:
  - Toggle labeling mode button
  - Click to label individual points
  - Select multiple points for bulk labeling
  - Zoom/pan state capture
- Nearby point detection (0.5 days, 15 minutes)

### `server/position_observers.R`
**Purpose**: Position editing functionality
- `setup_position_observers()`: Handles:
  - Find ML position button (maximum likelihood)
  - Toggle manual editing mode
  - Map click for manual position placement

### `server/export_handlers.R`
**Purpose**: Data export functionality
- `setup_export_handlers()`: Creates download handlers for:
  - Twilight data (labeled CSV)
  - Stapath data (CSV)

---

## Reusable Modules

### `modules/utils.R`
Utility functions used across the app:
- `time2plottime()`: Convert datetime to plot time
- `datetime2floathour()`: Convert to floating hour

### `modules/modal_calibration.R`
Self-contained calibration modal:
- `modal_calibration_ui()`: UI for plotly output
- `modal_calibration_server()`: Server logic with validation and plotting
- Returns function to show modal: `show_calibration(stap_idx)`

### `modules/map_module.R`
Template for future map module (currently unused)

---

## Usage Guide

### In `server_new.R`:
```r
server <- function(input, output, session) {
  # 1. Initialize reactive values
  rv <- init_reactive_values(.twl, .stapath, .twl_calib)
  list2env(rv, environment())
  
  # 2. Get known positions
  known_positions <- get_known_positions(.stapath)
  
  # 3. Setup map reactives
  map_data <- init_map_reactives(.g, .pgz, twl, stapath, input, thr_likelihood)
  list2env(map_data, environment())
  
  # 4. Initialize modules
  show_calibration <- modal_calibration_server(
    "calibration_modal",
    twl = twl,
    stapath = stapath,
    twl_calib = twl_calib,
    col = col
  )
  
  # 5. Setup observers
  nav_helpers <- setup_navigation_observers(
    input,
    output,
    session,
    stapath,
    show_calibration
  )
  update_stapath <- nav_helpers$update_stapath
  
  # 6. Render outputs
  render_plotly_output(input, output, twl, stapath, drawing, 
                       is_modifying, zoom_state, .light_trace)
  render_map_output(output, observe, has_map, map_data$extent,
                    map_display, contour_display, stapath, 
                    known_positions, col, input)
  
  # 7. Setup remaining observers
  setup_drawing_observers(input, drawing, stapath, twl, 
                          map_likelihood_fx, update_stapath, session)
  setup_labeling_observers(input, is_modifying, twl, zoom_state, session)
  setup_position_observers(input, stapath, is_edit, map_likelihood, session)
  setup_export_handlers(output, twl, stapath, .tag)
}
```

---

## Key Design Patterns

1. **Separation of Concerns**: Each file handles one specific feature
2. **Functional Programming**: Most modules export functions, not objects
3. **Dependency Injection**: Functions receive their dependencies as parameters
4. **Return Values**: Setup functions return helper functions for cross-module use
5. **list2env Pattern**: Unpack lists into environment for cleaner code
6. **Observer Pattern**: All user interactions trigger observers
7. **Reactive Programming**: Data flows through reactive values

---

## Testing Strategy

```
Unit Tests (R package structure)
├── test-utils.R              # Test time conversion functions
├── test-reactive_values.R    # Test initialization
├── test-map_functions.R      # Test likelihood calculations
└── test-modal_calibration.R  # Test calibration logic

Integration Tests (shinytest2)
├── test-navigation.R         # Test prev/next buttons
├── test-labeling.R           # Test twilight labeling workflow
├── test-drawing.R            # Test stap add/remove/edit
└── test-export.R             # Test download handlers
```

---

## Migration Path

### Phase 1 (Current): Both servers exist
- Keep `server.R` as reference
- Test `server_new.R` thoroughly
- Validate all functionality works correctly

### Phase 2: Switch to modular version
1. Rename `server.R` to `server_old.R`
2. Rename `server_new.R` to `server.R`
3. Update any documentation references

### Phase 3: Further refactoring
- Move plotly output to a proper module
- Extract more reusable components
- Add unit tests for each module
- Document function parameters with roxygen2
- Create vignettes for common workflows

---

## Benefits of Modular Structure

1. **Maintainability**: Each file focuses on specific functionality (~50-200 lines)
2. **Testability**: Individual functions can be unit tested
3. **Readability**: Clear separation of concerns
4. **Collaboration**: Multiple developers can work on different features
5. **Reusability**: Modules can be used in other Shiny apps
6. **Debugging**: Easier to locate and fix issues
7. **Documentation**: Each file is self-documenting

---

## Additional Resources

- **Package documentation**: `?geolightviz`
- **GeoPressureR guide**: https://raphaelnussbaumer.com/GeoPressureR/
- **Issues**: https://github.com/Rafnuss/GeoLightViz/issues
