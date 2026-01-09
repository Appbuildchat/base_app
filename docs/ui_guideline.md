High-level structural and architectural guideline for building screens like MarketplaceScreen

1) Screen architecture

- Overall layout flow
  - Screen uses Scaffold with SafeArea and a vertical Column as the main axis.
  - The body stacks fixed-height sections at the top and a single scrollable content area below using Expanded.
  - Bottom navigation is a persistent custom bar provided via bottomNavigationBar on Scaffold.

- Top-level building blocks and their purpose
  - Header (top app bar)
    - Holds branding on the left and global actions (search, notifications, profile) on the right.
    - Purpose: global, cross-screen actions and identity. Visually separated from the rest of the content with a thin divider.
  - Segmented tab bar (below header)
    - A custom two-option segmented control within a pill container.
    - Purpose: high-level mode switching for the whole screen (e.g., Marketplace vs. Community).
  - Content area (main section)
    - Composed of:
      - Filter bar: screen-level controls like Filter and Sort on the left and a view-mode toggle on the right.
      - Categories: horizontally scrollable chips/items to refine context quickly.
      - Product grid: the primary scrollable region showing items in a grid.
    - Only the grid scrolls; the filter bar and category row remain pinned at the top of the content area.
  - Bottom navigation (persistent)
    - Three items in a row, with a prominent center action.
    - Purpose: primary app-level navigation; equal width per item.

- State
  - Local state tracks selected tab and selected bottom-nav index.
  - GestureDetector-based taps mutate state via setState. For larger apps, this can be abstracted into a shared state solution without altering the UI structure.


2) Component design patterns

- Header
  - Composition: Container with bottom separator -> Row {left brand text, right actions Row} -> each action is an icon-only circular button.
  - Information hierarchy: left-side brand is the anchor; right-side actions are secondary and compact.
  - Shape and style: flat bar with a subtle bottom separator; action buttons are compact, circular, and icon-centric.

- Segmented tab bar
  - Composition: pill-shaped container housing two Expanded tab buttons.
  - Each tab is a GestureDetector wrapping a pill button with centered text. The selected tab appears filled; the unselected one appears flat/transparent.
  - Information hierarchy: tab labels are the only content; visual selection provides clear mode indication.
  - Shape and style: pill group with pill children; rounded, soft shapes; no icons in tabs.

- Filter bar
  - Composition: Row with left-aligned filter/sort pill buttons and a right-aligned view toggle icon.
  - Filter buttons are chip-like: a pill container with an icon and a text label.
  - Information hierarchy: filter/sort controls take precedence; view toggle is an affordance aligned to the far edge.
  - Shape and style: chip-like pills with icon+label; section separated from content with a thin divider.

- Categories
  - Composition: fixed-height container -> horizontal ListView.separated -> each item is a Column with a rounded media tile (square/circle-like) and a caption below.
  - Information hierarchy: the colored/filled tile draws attention; the caption clarifies the category.
  - Shape and style: rounded tiles for category avatars; short single-line captions; consistent spacing between items.

- Product grid and product card
  - Grid
    - GridView.builder with a fixed number of columns and consistent spacing.
    - The grid is the only scrolling child in the content area and is wrapped in Expanded.
  - Card
    - Composition:
      - Container styled as a card (rounded corners, thin border, subtle shadow).
      - Stack:
        - Main Column:
          - Media area at top with rounded top corners (image placeholder, maintain aspect).
          - Padded details:
            - Title: medium emphasis, up to two lines with ellipsis.
            - Price: higher emphasis and larger/stronger type.
            - Location row: small icon + single-line text with ellipsis.
        - Overlay action (favorite) positioned at the top-right: small circular button with an icon.
    - Information hierarchy: title (identification) -> price (primary actionable info) -> location (context). Price is the most visually prominent among the text elements.
    - Shape and style: rounded card with subtle elevation; top media area; small overlay action button.

- Bottom navigation
  - Composition: Container with a top separator -> Row of three Expanded items.
    - Left and right items: Column with icon and optional label beneath.
    - Center item: prominent circular primary action button (larger than others).
  - Interaction: each item is a GestureDetector; selected state updates icon/label emphasis.
  - Shape and style: flat bar with top separator; equal-width items; circular center action.

- Common micro-patterns
  - Spacing: consistent horizontal padding on sections; SizedBox used for small inter-element gaps.
  - Separators: thin container borders at section boundaries instead of Divider widgets.
  - Icons: used for actions and metadata; small sizes for metadata, medium for actions, larger for placeholders.
  - Text overflow control: maxLines with ellipsis used for long strings.


3) Reusable conventions and patterns

- Layout and composition
  - Use a Column in the body with:
    - Fixed-height sections stacked at the top (header, tabs, filters, categories).
    - A single scrolling child wrapped in Expanded (list or grid).
  - Keep header and bottom navigation consistent across screens; swap out the content area per feature.
  - Prefer section containers with consistent internal padding and a thin separator to delineate structure.

- Cards and surfaces
  - Card-like elements:
    - Rounded corners, light border, subtle shadow for elevation.
    - Top media area with rounded top corners; content below with internal padding.
    - Use a Stack to add small overlay actions (favorite, share) at a corner.
  - Text hierarchy inside cards:
    - Title: medium emphasis, concise, truncate to a few lines.
    - Key value (e.g., price): highest emphasis.
    - Metadata: compact row with a small icon and truncated text.

- Lists and grids
  - Use GridView.builder for product/item collections; keep a stable column count per breakpoint and consistent spacing.
  - Use ListView.separated for horizontal carousels (categories, chips) to ensure visual rhythm with consistent separators.
  - Constrain horizontal lists to a fixed height and keep items compact with a clear label.

- Tabs, chips, and filters
  - Implement high-level mode switching with a custom segmented control (pill group with pill children).
  - Represent screen-level filters and sorts as chip-like pill buttons with icon + label, placed above the main list/grid.
  - Keep filter/sort controls left-aligned and secondary toggles (e.g., view mode) right-aligned.

- Navigation
  - Custom bottom navigation with three slots:
    - Left/right: icon + optional label.
    - Center: prominent circular action button.
  - Use equal-space distribution via Expanded; reflect selection by changing icon/label emphasis.

- Interaction and state
  - Use GestureDetector or InkWell for taps on custom controls.
  - Track selection state at the screen level (e.g., selected tab/index) and update via setState or your preferred state management pattern.
  - Provide visual feedback for selected vs. unselected states through contrast and fill vs. outline styles.

- Spacing, sizing, and typography
  - Apply consistent horizontal padding for all top-level sections.
  - Use small, consistent gaps between inline elements and between stacked text elements.
  - Maintain a clear typographic scale: metadata small, titles medium, key values strong.
  - Use text overflow handling to protect layout stability.

- Section boundaries and structure
  - Separate major sections with subtle top/bottom borders.
  - Keep non-scrolling top sections grouped and visually cohesive so only one scrollable context exists per screen.

- Code organization
  - Encapsulate each section into private builder methods (e.g., _buildHeader, _buildTabBar, _buildFilterBar, _buildCategories, _buildProductGrid, _buildBottomNav).
  - Extract reusable widgets for:
    - Header action button (icon-only circular).
    - Segmented tab button.
    - Filter chip button (icon + label).
    - Category chip (rounded tile + label).
    - Product card.
    - Bottom nav item and center action.
  - Keep simple data models for list items (e.g., Product, Category) with only the fields required by UI.

- Accessibility and robustness (recommended)
  - Ensure touch targets meet minimum size guidelines for all icon buttons and pills.
  - Add semantics labels for icons and interactive elements.
  - Consider responsiveness by adapting grid column count at different screen widths while keeping spacing and aspect ratios consistent.

- Example screen skeleton (conceptual)
  - Scaffold
    - SafeArea
      - Column
        - Header
        - SegmentedTabBar
        - Content (Column)
          - FilterBar
          - HorizontalCategories
          - Expanded(ScrollableListOrGrid)
    - BottomNavigation

By following these patterns—column-based layout with pinned utility sections, a single scrollable body, pill-based controls, rounded cards with overlay actions, and a custom bottom nav—you can build new screens that feel consistent with the base design while being flexible for different content types.