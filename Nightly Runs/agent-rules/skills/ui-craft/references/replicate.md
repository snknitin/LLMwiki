# Replicate: build from an image, a wireframe or a site

Use when the person gives you a picture of what they want: a screenshot of an app or site they like, a Dribbble shot, a hand-drawn sketch, a wireframe, a Figma export, or a URL. They can paste or drag the image into the chat, give a file path, or give a link (screenshot it yourself). Read every image with your vision (Hermes: its vision tool) before anything else.

## First, which kind of "like this"?

If they didn't say, ask once, with the recommended answer first:

- **Exactly like this** (recommended when they said "exactly", "same as", "copy", "replicate", or gave a single finished design): match layout, proportions, spacing, type, colours and details as closely as you can. Your own taste stays out of it.
- **This layout, my app's look:** keep the structure and order exactly; style it with the project's existing tokens (or a ui-craft brief if it has none). The usual reading for a grey wireframe.
- **Inspiration only:** take the palette, type feel, density and mood into a ui-craft brief; don't copy the layout.
- **Mix:** "layout from image 1, colours from image 2": take each named part from its image, like combining options.

## Exactly like this

1. **Measure the reference before building.** Write a short spec in the reply:
   - **Frame:** the image's width and height; the viewport it represents (a 2880px-wide screenshot is usually a 1440px screen at 2x).
   - **Regions:** every block from top to bottom and left to right, with its position and size as a fraction of the frame (sidebar 18% wide, header 64px tall at 1440). Name the grid: columns, gutters, outer margins.
   - **Elements:** every visible piece in order, with its real text copied exactly, icon, image and state (selected tab, filled button).
   - **Colours:** sample them, don't guess: `python <this skill's folder>/scripts/refkit.py palette ref.png` (needs Pillow: `pip install pillow`) lists the main colours as hex with their share of the image; `refkit.py pick ref.png X Y` gives the exact colour at a point. Map each to a role (ground, surface, text, muted, border, accent).
   - **Type:** the family (identify it, or the closest Google Font: say which and why), size, weight, line height and letter spacing for each text style, measured in the image and converted to CSS px at the target width.
   - **Spacing and shape:** paddings, gaps, radii, border widths, shadows, measured in px at the target width.
2. **Build it** at the reference's viewport: HTML/CSS mockup first, or straight in the project's code if they asked for that. Use the measured values as tokens.
3. **Compare and fix, up to three rounds.** Screenshot your build at exactly the reference's size, then `refkit.py compare ref.png shot.png compare.png` puts them side by side with a heat map of the differences. Look at it region by region; list what differs (position, size, colour, font, missing element) and fix the biggest first. Stop when what remains is smaller than you can see at 100% zoom, or after three rounds, and say what still differs.
4. **Other widths.** If they gave only a desktop image, derive the phone layout by stacking regions in reading order with the same tokens, and say so; ask whether phone matters if it's unclear.

Hold the quality floor quietly: real text over images of text, keyboard focus visible, contrast at least 4.5:1, nothing clipped, hover and pressed states. If matching the image exactly would break one of these (grey 11px body text, a 2.5:1 button), match it and mention the problem in one line with the fix you'd suggest, instead of silently changing their design.

## Wireframes and sketches

- A wireframe fixes structure, order and proportion; it rarely fixes style. Unless they said "exactly, including the greys", read it as **this layout, my app's look**.
- Conventions: a box with an X or a mountain is an image; squiggles or grey bars are text (write real content in their place); a filled block is a button; a circle is an avatar or icon; arrows and handwritten notes in the margin are instructions to you, never text on the page.
- Hand-drawn lines are wobbly: straighten them onto a grid and equalise spacing that is meant to be equal.
- Annotations like "list of items", "chart here" or "user's name": build the real thing with plausible content in that domain.
- Anything you had to interpret (an ambiguous box, a missing state), list in one line each after building, so the person can correct it.

## Several images

Number them in your reply ("1: the dashboard screenshot, 2: the colour mood board"). Say which part you take from which, ask if that's unclear, and build one result, not an average of all of them.

## Copying someone else's product

Matching a site you admire for your own private use is fine. For anything shipped or public: no logos, brand names, photos, illustrations or written copy taken from the reference; use your own content and assets, and keep the layout and craft ideas. Say this once when the reference is clearly another company's product.
