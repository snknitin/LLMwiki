# Kole Jain: takeaways per video

What each video teaches, in playlist order (positions 1–53). Business-only videos (pricing, portfolio, case study) are kept short.

Video ids are YouTube ids (https://www.youtube.com/watch?v=<id>). Distilled from the processed captions of all 53 videos in the owner's "Kole Jain — UI/UX" playlist (YouTube Learning Center, 2026-10-27). Values shown only on screen in a video are missing; numbers are as stated in the narration.

### 1. Why the best software must LIE to you (S8DcTJm8pYM)
1. **Single input, several actions → wait to disambiguate.** AirPods wait 700 ms on a tap, because a double or triple tap means skip. A phone pause takes under 300 ms because each action has its own button. In a list where a click opens the detail page and a double-click renames inline, the single click must be delayed. Only add that delay if the secondary action is worth it.
2. **Non-competing actions → no delay.** Selecting a table cell highlights it instantly, because the first click is correct whether or not a double-click follows. Only add a click delay when the first action would be wrong if a second click comes.
3. **Submenu "safe triangle"** (Linear, Notion and Asana; documented by Ben Kamens in 2013). Draw an invisible triangle from the cursor to the top and bottom corners of the submenu. Keep the submenu open while the cursor moves inside it, but only if it moves fast enough. A slow move means the user is aiming at the item above.
4. **Tooltips:** delay only on the first hover. After one tooltip has shown, adjacent tooltips appear instantly.
5. **Hover-to-reveal collapsed sidebar** (Notion): it only expands if the cursor dwells at the left edge long enough. A fast pass-through does nothing.
6. **Drag-to-reorder near an edge:** don't make auto-scroll a binary switch. Show where the item will land, and make the edge zone a gradient: the closer to the edge, the faster the scroll.
7. **ROAST: confirmation modal on delete.** It makes 99% of users confirm what they meant, to protect the 1% who didn't. Replace it with an instant delete plus an Undo toast, or a "Recently Deleted" list purged after 30 days. Gmail holds a sent email for 5 s so Undo works.
8. **Settings and editors:** save instantly and drop the Save/Cancel buttons. Autosave in editors. Provide version history as the way back.
9. **Keep a confirmation modal only for novel, irreversible actions**, such as bulk email to 10,000 recipients or sending money.
10. **Commit timing:** normal buttons commit on *release*, so pressing and dragging off cancels. Menu and popover triggers open on *press*, so press, drag and release selects in one motion. Pull-to-refresh, swipe-to-delete and Cmd-Tab show progress toward the commit and can be reversed (Esc) until release.

### 2. The secret behind weirdly perfect UI designs (neE6wOuBIP8)
1. **Receipt alignment:** text hard left, numbers hard right, no dividers, little whitespace. The two edges hold everything together. Center only what isn't meant to be read.
2. **Edge rule:** in compact UI (cards, chat inputs, Kanban cards, sidebars), every element should touch at least two edges. Edges come from the card, or from rows such as the bottom of the avatar+name line.
3. **ROAST: a profile card with too many buttons that don't follow edges.** The tempting fix (stretch the buttons, hide the rest in a corner menu) looks better, but hiding isn't the fix. Instead, move content so it clears an edge, or *manufacture* a new edge: line the buttons up with the avatar to form a solid line for the content below.
4. **Checklists look "perfect" because each row is the edge for the next.** If you swap in larger icons, the bottom edge is lost; add a subline to restore it.
5. **ROAST: rules or rows running the full screen width.** The edges are unchanged but it reads worse. Constrain the line length.
6. **ROAST: adding whitespace to fix density.** It only makes the page longer. The real problem is *undifferentiated* content. Fix it by adding avatars wherever a person is referenced and grouping by a key such as due date, so any task can be found in about 1 s.
7. **ROAST: "explaining harder"** with more labels, comparisons and tooltips. Swap plain text for icons, diagrams and universally known symbols (a stop sign needs no words). Links blue and underlined; categories as chips, which also allows editing tags inline.
8. **Checkbox logic for emphasis:** an unchecked box is a thin border with no color; checked earns a fill and a check. **ROAST: a settings panel where every value chip looks the same** although all are defaults, "like six checkboxes that are blue when off". Make default values gray so non-default values stand out. Emphasis comes from the difference from neighbours: change the surroundings rather than adding color or bold.
9. **ROAST: card soup:** "borders on borders and three radii all stacked together". Dissolve the cards with one column divider line. That column edge does the cards' job, and section headings do the grouping.

### 3. The one thing vibe coding CAN'T fix about your website (RCneB_MQ7qs)
1. **ROAST: a site for restaurant owners with no images anywhere.** Kole calls that a "telltale sign" of vibe coding, robotic and soulless. Replace it with imagery of the user's world, plus one actionable headline that promises what the product does (Actual uses laptops and keyboards for freelancers).
2. **Identity process:** start from one moody image: crop, darken, add noise, add the brand name. Pull an earthy palette from the images and take accent colors from a palette site. Add textures from the domain (counter, pots and pans, a tablet).
3. **Fonts:** keep a good sans. **ROAST: a monospace font that doesn't fit the brand.** Replace it with a serif to add personality, "like a printed menu". Draw feature icons in the accent colors.
4. **"Frankenstein" wireframe:** borrow the structure of each section from a different reference site, then throw away their skin and keep only the wireframe. His picks:
   - Actual-style hero.
   - Better Stack logo ribbon.
   - Superpowered how-it-works, but less step-like and with much bigger images.
   - Miro full-screen color tabs with about 90% of the text cut.
   - Attio testimonials minus the lines.
   - Wise-style heavy bold CTA, left-aligned, on an image.
5. **Hero build:**
   - Brand background color or image, plus noise (which also helps text contrast).
   - Heading split across lines.
   - Buttons placed at least 2× the heading-to-subtext gap below the subtext. Large type already has space under its baseline.
   - Scattered assets that aren't random: larger elements below, smaller on top, and always a safe margin around the text.
   - Darken the edges (vignette) to pull the eye to the center.
6. **Vary section treatments** inside one identity:
   - Next section: image background, stronger noise, mid-size text.
   - Features: cream background with no noise for a "clean software" feel, a graph-paper texture, and large dominating images.
7. **Same wireframe, different identity:** swapping the identity on one wireframe gives wildly different feelings, so define layout and identity separately.
8. **Motion identity:** choose one or two motion motifs and repeat them site-wide (Amigo AI: a pull-away on scroll plus gradient transitions between sections). Direct motion at the focal point.
9. **ROAST: a hard break between the hero and the next section.** Slide the hero elements off and blur the hero text while the next section slides over it. Do the reverse on the CTA.
10. **Important feature images** auto-rotate on a timer, with a slight zoom on hover.

### 4. The stupid simple way to learn UI/UX design in 10 minutes (9WVt1CelBfg)
1. **Hero spacing:** subtext 8 px below the heading, eyebrow 12 px above it, buttons 32 px below. The proximity order (heading+subtext, then eyebrow, then buttons) creates the grouping.
2. **Copy length:** headline 7 words, subtext 14 words.
3. **Nav:** small and out of the way, with only the primary sign-up/member CTA prominent.
4. **Hero image:** never obstruct its focal point. Text sits above, below or left of it, leaving the center and right free. The image background must be calm: a busy image kills the text.
5. **Hierarchy by color, not size:** two stat lines both at 15 px; the secondary line at 55% opacity.
6. **Hero layout menu:**
   - Text+image pairing: text left/image right, image full-screen under text, text top/image below, or (rarely) text below the image.
   - Text alignment: centered, left, or split (body and CTA kicked to the right).
   - Visual: bordered image, full-bleed image, or a slowly rotating carousel.
7. **The content decides the layout.** A profound statement gets centered, larger type and lots of space. A long features list becomes a bento grid so nothing is lost on scroll.
8. **The same layout in two "flavors":**
   - Friendly: warm background, colorful visuals, round corners, large bubbly buttons.
   - Premium/pro: less rounding, less colorful and more premium imagery, background noise.
9. **UX onboarding decisions:**
   - Name and email, with an escape hatch to login.
   - Email verification: either block, or remind gently and let them continue.
   - Workspace plus a team-size question.
   - Branch: team users get "invite members"; solo users skip it.
10. **ROAST of his own old portfolio:** huge animations, giant text, everything moving. Replace with smaller, tasteful animations.

### 5. The 3 dashboard UI flaws that give away you've never built one (Ksx9C2-3yMo)
1. **Data drives form (tables):**
   - Finite-category fields (department, employment status) → chips.
   - Numbers right-aligned so digits line up by place value.
   - Long text truncated.
   - Inactive or deactivated rows shaded or dimmed.
2. **ROAST: time-ordered data in a table.** Make it a timeline, tucked into a sidebar pop-out or a second column beside the table.
3. **Dashboard color comes from the data, never sprinkled in.** A red icon or chip marks an urgent action, avatars show who did what, and a summary chart rolls up the time dimension.
4. **Progressive disclosure:**
   - Share goes in a popover, not a new page and not permanent side UI.
   - Inside it, search is the primary control, at the top.
   - "Remove user" appears on hover, with a tooltip.
5. **"Spectrum of explicitness":** placement runs from a global, always-visible button with a full label (high), to an icon only, to an icon on hover only (low). Place each action by its frequency and importance. Apple Reminders hides secondary actions behind swipes.
6. **ROAST: an onboarding modal with six bullet points at first login**, forgotten the moment it's dismissed. Instead: one tooltip pointing at the most important action, then the next one or a small checklist in a corner. That is sequencing, not hiding.
7. **"Invisible UI" that dense screens need:** a copy chip on cell hover, a comment triangle indicator, drawers, modals, hidden states, feature announcements, onboarding pop-ups.
8. **ROAST: beginner dashboards with no tooltips.** Assume icons and ambiguous labels aren't understood and give each one a tooltip.

### 6. The 4 Levels of Landing Page UI/UX Design (eMMiLeo_UGI)
1. **Level 1 roasts** (about $500, 2/10, template-like):
   - Text-left/image-right alternating all the way down.
   - Stock images unrelated to the product.
   - Sharp image corners against rounded buttons (inconsistent radius).
   - Vague, overlong copy that repeats the company name already in the nav.
   - A flat nav where every item looks identical, with no emphasis on sign-up and the weight on the right.
   - Brand blue "applied pretty haphazardly to anything that will reasonably take it".
   - Images doing all the color work.
   - No motion beyond one hover.
2. **Level 2** (about $2k, 6/10):
   - Stacked hero (text above, visual below).
   - The real product dashboard instead of stock imagery.
   - Color comes from the dashboard screenshot, which frees the buttons to be white.
   - Shorter, punchier headline.
   - Nav: important buttons outlined, links centered for balance, small hover dropdowns.
   - **The hero CTA uses the same label as the nav CTA**, so users know they go to the same place.
   - Simple load animations.
3. **Level 3** (about $6–10k, 8/10):
   - Crop or zoom into the important part of the product UI.
   - Full-length vertical lines frame the content, which also scales to large screens.
   - A row of 4 cards → bento grid; a 3-card row → a clickable multi-select (tabs with a preview).
   - Shorter sections.
   - Hierarchy through color and size (his caution: overdone, the headline crushes the subline).
   - Trust elements: a badge, logos, and a button to a social-proof page.
   - Mega menu.
   - Brand color returns on the primary CTA, with an icon.
4. **Level 4** (over $10k, 10/10):
   - Visuals built to show exactly what the product does.
   - Layouts molded around the content rather than rigid lines.
   - Slightly looser type spacing, with line widths chosen to form "leading lines" into the content.
   - **Copy moves from "what it does" to "how it helps"** ("collect and analyze data quickly" → "turn it into decisions").
   - Color threaded through the page via curated visuals.
5. **L4 motion upgrades:**
   - The multi-select transition gets a blur effect.
   - **Mega menu stays open while moving between top-level items**, sliding content left or right instead of closing and reopening.
   - The logo strip's CTA appears on hover instead of a permanent button under it.
6. **Page flow:** L1 is sections dropped on top of each other. L4 sections are made for their space and lead into each other (a logo strip flowing into analytics; a dashboard fade-out segueing into features).

### 7. Mobile App UIs in 8 minutes (Gfsd8NNuD9g)
1. **Navigation:** a floating bottom tab bar with the main action broken out. Five links is the hard limit; 3–4 is ideal. Targets are always at least 44 px.
2. **Too many sections for a tab bar?** Make the sidebar the home page (Notion): recents at the top, counts on the right so it doesn't feel lopsided, and a big search bar or action button at the bottom.
3. **Top bar:** bell plus a more menu, contextual per page.
4. **ROAST: squishing desktop UI down to fit.** Type and spacing stay about the same size or get *larger*: iOS base text is 17 px against 13 px on macOS. From the desktop's many modules, pick ONE per screen.
5. **One scroll direction per section:** vertical stack *or* horizontal carousel, never both. Desktop can lay out in two directions.
6. **Four building blocks:** cards (the main one, standing in for whitespace), text/links, images, inputs. **ROAST: cards nested inside cards** create padding on padding and cramp everything; group with whitespace instead.
7. **One screen does one thing** (home is the exception). **ROAST: recent notes or template suggestions inside the editor.** New things go on a new page, not into a new layout. When the user must keep context, use a **bottom sheet**: title, search, a check and an X, any height, dismissible by gesture.
8. **Gestures:**
   - Swipe-back: the background moves left about 35% and then animates right.
   - Bottom sheet: the background zooms out, and zooms back in on dismiss.
   - Swipe up to search (Slack).
   - Long-press, the mobile right-click: blur the rest of the screen, zoom the element slightly, show actions, or a rich preview as on iOS.
9. **Contextual chrome:** opening a note hides the tab bar and shows formatting and share at the top. A template picker shows only confirm and X.
10. **Empty states:**
    - First run: one full-screen empty state pointing at the + button, plus a popover explaining it, rather than three "add X" cards.
    - No search results: imagery, acknowledge that nothing matches the keywords, offer suggestions in case of a typo, and give an exit action.

### 8. Every UI/UX Concept Explained in Under 10 Minutes (EcbgbKtOELY)
1. **Signifiers:** a container around items says they're related, a filled container says selected, gray text says inactive. Other signifiers: press states, active-nav highlights, hovers, tooltips.
2. **ROAST: a card that "looks like a spreadsheet".** Fix the hierarchy (ride-booking example):
   - Image at the top for color and scanning.
   - The most important item large and bold at the top.
   - Time and date smaller, below it.
   - **Price top-right, right-aligned and blue.**
   - Locations smaller, with icons and alignment showing from→to without the words "from" and "to".
3. **Grids are guidelines:** 12 columns on desktop, 8 on tablet, 4 on mobile, for structured or repeating pages (galleries, blogs). Custom landing sections may ignore the columns.
4. **Spacing:** 32 px between every hero element, with related pairs grouped tighter (announcement+heading, heading+subtext). The 4-pt grid exists so any value can be halved.
5. **Fonts:** one sans-serif is enough; you'll almost never need more.
6. **Large-heading "hack":** letter-spacing −2% to −3%, line-height 110–120%.
7. **Type scale:** at most 6 font sizes on landing pages. On dashboards the range shrinks and nothing goes above about 24 px.
8. **Color:**
   - One primary brand color: lightened for backgrounds, darkened for text. That's the start of a ramp, which drives chips, states and charts.
   - Semantic colors: blue = trust, red = danger/urgency, yellow = warning, green = success. Color for purpose, never decoration.
9. **Dark-mode fixes:**
   - **ROAST: a light card border with too much contrast** → lower it.
   - No shadows in dark mode, so cards are *lighter* than the background.
   - **ROAST: a chip that's too bright** → dim its saturation and brightness and flip it for the text.
   - Dark themes can use deep purple, red or green, not only navy or gray.
10. **Shadows, icons, buttons, states, overlays:**
    - **ROAST: shadows that are too strong.** Lower the opacity and raise the blur. Cards need less shadow, popovers more. Inner plus outer shadows make tactile buttons. "If the shadow is the first thing you notice," it's wrong.
    - **ROAST: icons that are too large.** Icon size = the text's line-height (e.g. 24 px), then tighten the text.
    - Ghost button: no background until hover (sidebar links are ghost buttons). Button width ≈ 2× its height, via horizontal padding.
    - Every button needs default, hover, active/pressed and disabled states, plus loading (spinner) when needed. Inputs need focus, error (red border plus message) and warning states.
    - Copy micro-interaction: a "Copied" chip slides up.
    - **ROAST: a full-screen dark overlay on a hero image.** Use a linear gradient into a text-readable color, optionally with a progressive blur on top.

### 9. 5 SaaS UI/UX mistakes that SCREAM you Vibe Code (PDcQJOPby1k)
1. **ROAST: emojis as icons.** Use an interface icon set (Phosphor is his pick; Lucide works too).
2. **ROAST: AI-chosen colors** (bright, clashing). He changed the dark-blue backgrounds to dark green, removed the decorative icons, and widened the KPI cards with micro charts. Get color from charts, not from buttons and icons.
3. **ROAST: the same 4 KPI cards repeated three times** in a small app. Show each metric once, in the place it belongs (dashboard or a new Analytics tab).
4. **Sidebar:**
   - **ROAST: per-item counts** (clicks, links) in the nav where nobody needs them → remove them, left-align, tighten spacing.
   - **ROAST: the AI gradient circle with initials** → an account card whose links open in a popover on click.
   - Merge Settings, Billing and Usage into one item.
5. **ROAST: busy list cards.** Collapse the action buttons into a ⋯ menu, move the date to the center, reduce chips to icons only, put clicks on the right.
6. **Create-link flyout:** sparse fields in a big panel → a modal. Collapse advanced options by default and add the missing fields (domain switcher, description).
7. **ROAST: a card that does nothing** → delete it (a common AI pattern).
8. **KPI cards** → a two-column layout with small donut charts; tabs for sub-areas.
9. **Pricing table fixes:**
   - **ROAST: 5 plans** → drop at least one.
   - **ROAST: prices that look out of order** because the discounts are hidden → show the actual discount.
   - Shrink the plan name ("no one cares") and enlarge the monthly price.
   - Rename "Business" to "Enterprise".
   - Show what the next plan adds over the current one (Resend and Supabase pattern).
   - Include a billing email and payment method.
10. **Analytics and landing page:**
    - A toggle that splits the data per link for comparison.
    - A stat row with colored icons.
    - **ROAST: a boring bar chart for geography** → a shaded-region map with the data list beside it.
    - Landing page: **ROAST: "lame" generic icons** → product graphics (skewed link cards, edited screenshots of real pages).

### 10. Why the 60-30-10 Rule is RUINING Your UI Designs (66oOi9OLMCw)
1. **His position:** 60-30-10 doesn't fit product UI. Vercel is about 90% black, 8% white and 2% red.
2. **Backgrounds:** Linear 99% white, Notion 100%, Vercel 98%. Pure white is fine.
3. **Neutral counts:** a landing page needs 3–5 neutrals. A product needs 4 background layers, 1–2 strokes and about 3 text colors, before charts and hover states.
4. **App frame/sidebar:** only slightly darker than the content. Mercury adds 2% blue to its sidebar.
5. **Light-mode surfaces:** three valid models. Dark background with lighter cards (Vercel), light background with darker cards (Notion), or monochrome layers (Supabase). Darker cards reuse the sidebar color. Lighter cards can be pure white, which is a reason *not* to use pure white for the background.
6. **ROAST: a thin black border on cards.** Use a border of about 85% white (light gray) that defines the edge without overpowering it.
7. **Buttons and text:**
   - The more important a button, the darker it is (ghost → gray → black with white text). Multipurpose buttons sit around 90–95% white.
   - Text lightness: headings about 11%, body 15–20%, subtext 30–40% (as % white, i.e. HSL lightness).
8. **Accent as a ramp:**
   - Main color 500/600, hover 700, links 400/500 (ramp from uicolors).
   - Dark mode: primary 300/400, hover 400/500.
9. **Dark mode:**
   - Double the distance between neutral steps: light-mode steps are about 2% apart, dark-mode steps 4–6%.
   - Dim the text and brighten the borders.
   - Surfaces always get lighter as they rise; a raised card is lighter or gets a border.
   - Dark mode is not flexible the way light mode is.
10. **Semantic, charts and theming:**
    - Destructive actions are red even when the brand is purple; status colors are needed even in a black-and-white brand.
    - Charts: never all-neutral, never just the brand ramp. Use OKLCH with fixed L and C and step the hue by 25–30 per series, so colors are equally bright (green otherwise looks neon next to blue).
    - **Theming any neutral palette:** in OKLCH, per neutral, lower L by 0.03, raise C by 0.02, set the hue to the theme. He says this works even better in dark mode.

### 11. Design macOS Apps EXACTLY like Apple (Vy0KKvZJRH8)
1. **Native means a system that's there when needed, not a destination:** popovers, extra windows, notifications.
2. **Quick capture:** a global shortcut (Cmd+Shift+S in his app) opens a minimal panel, like Spotlight or Raycast:
   - Contents: no traffic lights, a drop area, an input, buttons with shortcut hints, native background blur.
   - Enter collapses it into a toast that slides off screen.
   - This is optimistic UI: assume the save succeeds (Apple Mail moves mail to trash before the server deletes it).
3. **App ≠ landing page:** an app holds the user's own content. Apple's utility layout is global actions on top, nav sidebar, content in the center. Traffic lights are integrated into the top bar or sidebar like any other element.
4. **The top ~50 px is the window-drag zone**, so keep actions out of it and let it breathe.
5. **Minimum UI:** skip the sidebar when navigation is only browse and search. Ask "What is the minimum UI needed to let the content shine?"
6. **Progressive disclosure:** an empty state invites the first save. Filters stay hidden until there's content, and full metadata only shows when an item is clicked.
7. **Light/dark:** direct inversion produced too much contrast in the inverted (light) theme. Collapse the colors closer together there. Design the two as "different but consistent", not exact opposites.
8. **Search is always prominent:**
   - A floating search bar plus a slide-out preview rather than a command palette, since palette items jump to new screens and his app stays on one screen.
   - Show the result count and an X to clear in the bar, the query top-left, and a back arrow to browse.
   - Search by image content.
   - The bar sits collapsed at the bottom and expands on click or shortcut.
9. **Every keyboard shortcut needs visible feedback** (a micro-animation or state change): "If you don't see a change, you assume that something went wrong."
10. **Drag, drop, actions and onboarding:**
    - Drag and drop both in and out, from anywhere.
    - A system share button.
    - A floating action bar in the preview (copy, find, delete).
    - Onboarding modal that you close by *performing* the shortcut.
    - A shortcut cheat sheet in the settings popover.

### 12. 4 UI Design Hacks to KILL boring designs (SfX43uIubj4)
1. **ROAST: "corporate AI mush"**, where modern has become a synonym for sterile (Mailchimp before and after 2020).
2. **Context objects explain the product** before anyone reads (money, invoices and crypto coins around a centered message). Removing them makes the page empty, not clearer.
3. **Recipe:**
   - Center the text.
   - Surround it with doodled illustrations of the domain, small "twinkles" and a few scribbles.
   - **ROAST: filling every empty spot**, which is clutter. Keep generous space around the text so the objects are "context, not clutter".
4. **Off-grid placement:** objects should thin out the further they are from the center, pulling the eye inward. Tilts that point the eye away "look off".
5. **Match the playfulness level** to the brand: blobs and fun colors (playful) through doodles and neo-brutalism (Gumroad) to realistic imagery (professional).
6. **Entrance motion fits each object:**
   - A star rotates and pops in.
   - A hot-air balloon flies in from off-screen, then bobs slowly.
   - A calendar moves and rotates in.
   - **ROAST: no entrance, or a "robotic fade in".** Use easing, plus parallax on the margin objects while scrolling.
7. **Kinetic text:** words turn into objects. "deadlines" becomes a progress bar that fills, rises out, and is replaced by the word. "paid" becomes bouncing dollar signs that drop down. A checkbox ticks at the end. The goal is to draw attention to the text, not complexity.
8. **Small hover interactions on almost everything**, so simple isn't bland.
9. **Copy and 404:**
   - Friendly, plain copy: "we sweat the details" beats "we take pride in our attention to detail" (Basecamp).
   - 404 pages are where you can be most quirky (Mobbin's quiz, Pixar's character, the snake game). Tie them to the site's voice.

### 13. Master the 3 Types of Mobile UI Swipe Interactions (14h1VnkQvIc)
1. **Horizontal card carousels beat vertical stacks.** **ROAST: rigid, linear swiping.** Open up the easing curve for bounce and momentum. Almost never use linear easing; the curve sets the tone (snappy and performant, fun and springy, or slow and smooth).
2. **Depth:** skew cards as they reach the screen edge to suggest a 3D ring. Or treat the screen edge as a horizon that shrinks items approaching it, with a circular swipe path.
3. **Always add page indicators.** Upgrade them from a plain highlight to a fluid, "magnetic" stretching dot.
4. **Duplicate every swipe action with a visible button** (Gmail: swipe to delete *or* tap delete).
5. **Page transitions follow the swipe direction:** the card expands to full screen, a tab expands behind it, the content fades up and in, and an elastic snap lands at the top. **ROAST: a plain slide-in new page.**
6. **Shared-element transition:** the tapped image zooms into the new page's hero image, for continuity.
7. **Swipe gestures can replace buttons** (swipe to add a friend). Add a long-press fallback menu.
8. **Sheets:** dismiss by swiping down, with buttons as well. The background zooms out and moves down as the sheet appears, and reverses on dismiss.
9. **Slide-to-confirm** for high-impact or irreversible actions (Resend's email send, buying crypto). It's much harder to trigger by accident than a button.

### 14. The DEFINITIVE process to present UIs like a pro (7cTdCu8HMgM)
1. **Plain background for the shot:** take the accent color, darken it and desaturate it toward gray so it doesn't out-pop the design. Add a faint shadow.
2. **Dark-mode shots:** large blurred circles of the accent color behind the UI as an ambient glow, or a glassy background with a soft gradient stroke on the edges.
3. **"Explode the image":** extend the UI's lines or patterns past the frame edge instead of cropping.
4. **Skew:** 2° vertical, −14° horizontal; don't over-skew. Pop the key panel out with an offset and shadow, optionally leaving a gray placeholder where it was.
5. **Multi-screen collage:** offset the screens and let them slide off the canvas. **ROAST: a grid-aligned stack.** Add a few degrees of rotation or a skew, and pop out the most important frame.
6. **Landing pages present best.** Dashboards are too fine-grained, so zoom into one section and animate it.
7. **Client meetings:** the goal is confidence, not wow. Use realistic device mockups or lifestyle shots (the latest Apple device).
   - AI mockups: prompt a green-screen MacBook in a styled scene (about 30 words of detail), punch out the green, skew the design in.
   - Small details in the scene sell it.
8. **Prototype the hidden polish:** swipe actions, the modal animating in, the delete sequence. "Don't describe, show."

### 15. The 7 Color Mistakes that RUIN your UI Designs (EOcY3hPMQkk)
1. **ROAST: every card a different bright color, most failing WCAG.** Recoloring them all in the brand purple makes it dominate an unimportant element. Fix: lighten it to a tint and use black text.
2. **Icons need no color:** their job is to be recognizable. Use color only for status (active tab).
3. **Remove color used for its own sake.** "Neutral balance" works for color the way whitespace does for layout.
4. **ROAST: a bright or sandy gradient page background.** Use a neutral gray background with a white or very light foreground. In dark mode, a darker background with lighter foreground surfaces. Tint the gray with a hint of the brand hue (Headspace tints its orange into cards).
5. **Light mode may reverse:** white background, gray-filled small elements (Dribbble's search bar), which helps accessibility. Sometimes drop a card's fill entirely and use just a border.
6. **Limited brand palette:**
   - Rotate the hue slightly for analogous colors (purple → blue or pink) or take the complementary color (yellow).
   - A brand orange that fails with white text: darken it, or use a complementary blue.
   - Examples: Mailchimp yellow plus turquoise; Airbnb bright pink plus deep pink.
7. **Pure black or white isn't wrong, but grays are usually better:**
   - Secondary metadata (file size and type) and labels in gray.
   - Borders lighter, once the grouping is clear.
   - Most text is light gray or dark brand-tinted, not black.
   - Dark mode lowers the brightness more aggressively, with white reserved for the most important text.
8. **ROAST: dark mode as an inverted light mode:**
   - Brighten the borders and the main card.
   - Light grays for text, pure white only for the logo and key figures.
   - Desaturate the logo or brand colors a touch.
9. **Semantic red:** **ROAST: a brand-purple delete button.** Delete is red. Notifications are flexible and can use the brand color.
10. **States by color:**
    - Hover: slightly lighter or brighter.
    - Pressed: slightly darker.
    - Disabled: desaturated (light gray with white text).
    - Mobile has no hover, so add a slightly darker press state.

### 16. Build a Dashboard UI in 8 minutes (B7k5rOgmOGY)
1. **Sidebar = the spine:**
   - Profile switcher at the top (avatar plus up/down arrows to signal it's clickable) instead of the logo.
   - Each link has a recognizable icon and a short title, so it works collapsed and has room for count or "new" badges.
   - Links grouped by relevance; Settings and Help at the bottom; dropdowns once the list grows.
   - An active-state indicator bar.
   - Optional: a highlighted feature slot, and notifications in spare space (Dub, Linear).
2. **ROAST: a dashboard like "someone emptied a drawer onto the screen"**, one that needs "a PhD to operate". Do one thing well, and put what matters most to this user in the main area: project status for project management, investments at the top for finance.
3. **Dashboard type is smaller**, with smaller steps between sizes than a landing page. The grid is followed more strictly.
4. **Example layout:**
   - A 2×2 grid: link management on top, key metrics below.
   - The top strip is for page actions (a filter dropdown and a "Create link" button).
   - List rows stay minimal: favicon, short link, target, date, clicks, plus a one-line description (GitHub-style).
5. **List rows:** a stacked list with dividers is less cluttered than a border around every row. Design the empty state. **Multi-select reveals a contextual "Bulk actions" button.**
6. **ROAST: decorative charts** "I don't know what these are". Use a basic line chart with grid lines and axis numbers ("everyone forgets those"), a summary figure and a date-range selector. Bar chart: per item, with favicons, plus a metric switcher (signups/conversions).
7. **Picking the container:**
   - **Popover**: simple context, non-blocking (display settings).
   - **Modal**: complex but tied to the current page, blocking (create link), followed by a confirming toast.
   - **New page**: large or permanent context (link detail), which then *requires* a back button or breadcrumb.
   - **Toast**: anything you need to tell the user without taking over the screen, including warnings and errors.
8. **Four dashboard building blocks:**
   - Lists/tables: separate rows by space, dividers or color. Tables need search, filter and sort.
   - Cards: border or fill. His preference is outlines in dark mode and fills in light mode.
   - Inputs.
   - Tabs: extra pages without cluttering the sidebar (Notion views).
9. **Dashboard motion is tame:**
   - Chart hover shows the value plus a % change bubble, or dims the other bars.
   - Optimistic UI: deleted items vanish instantly, with no awkward pause.

### 17. The 7 UI Components to Design Like Unicorn AI Startups (If7iCPDy2vk)
1. **A giant prompt box as the hero**, putting users straight into the product (ChatGPT and Gemini dropped their landing pages).
2. **The prompt box as a control panel:**
   - Previews for attached PDFs and images.
   - Pasted code collapses into a block (Replit).
   - Mode chips (brainstorm/data/email).
   - Context attach (Cursor).
   - Integration buttons (Drive, GitHub, Figma).
   - An advanced-mode toggle and a token-cost estimate above the input.
3. **Loading indicators are short, looping and fluid:** Notion's three bouncing dots, Claude's rotating star.
4. **Generation history:** a first-line or snippet preview, delete, and search, so history is "a workspace, not a waste basket".
5. **A memory panel:** storage usage, bulk delete, add facts to persistent memory. **ROAST: memory hidden in settings, or not shown at all.**
6. **Inline AI edit:** highlight text and type the change. Keep it compact: a few quick selectors and keyboard shortcuts (Claude, Lex, Notion AI).
7. **Research trail:** three animated steps (searching docs, extracting quotes, drafting answer) fading in one by one.
8. **Waiting:** stream the output word by word. Skeleton shimmer placeholders that the real content slots into exactly (Relume).
9. **A confidence pill** under each answer ("high confidence" / "unverified"), which shows the numeric score on click.
10. **Dark soft glass:** a semi-transparent rectangle, a subtle gradient, background blur, a 1 px border, a soft inner shadow, and a slow shimmer running along the border.

### 18. Stop Making Pretty UIs. Think Like a Product Designer (ADaQuZS04Rc)
1. **ROAST: designing only the happy path.** Design the empty, loading, success and error states:
   - Dub's empty dashboard: an animation, a message and a clear next step.
   - Vercel's build-status notifications.
   - An integration connect flow: an informative loading state, then success or error.
2. **Design flows, not sections:** for each screen, ask how the user got there and what they need next. Notion: after "Create teamspace", prompt to add members, with Skip. Hiring app: Email applicant → pick a template → offer to add more applicants → send. That's "three tiny decisions chained".
3. **Design system = trust and speed.** In the macOS dialog the primary-colored button is always the non-destructive one, and users rely on that. Linear keeps buttons, spacing and text styles identical in every context.
4. **A new modal should be assembled from existing parts:** template selectors, title, description and tags fields, actions at the bottom. It isn't about hundreds of components but "making a decision you can stick to".


### 19. The Formula Behind Truly Captivating UI Sections (tNMAFjzapOk)
1. Formula = **structure, then motion, then one surprise**. Get the layout clear before adding any animation.
2. **Roast (Fiddle Digital):** too many components, text split into separate floating elements, several pop-ups, small ornaments, complex shapes: "crammed, not crafted". **Replace with** the Link Kit approach: one clear grid, generous space around text, solid blocks of text, simple illustrations, big bold numbers.
3. **5-second wireframe test:** strip the content to grey boxes; if a 5-second scroll doesn't convey the idea, the structure fails.
4. **Roast (Micro, a PM app):** the product name sits in a corner at **12px**, and the hero photo reads like a wellness retreat ad. **Fix:** make the text the hero headline, fade the photo out, and show a real dashboard screenshot so it reads as software.
5. Motion must **point at the product**. Good: a side image morphs on scroll and becomes the next section's product view. Bad: Micro's decorative animations, which still haven't shown the product further down the page; Capsules, whose complex animations make navigation harder.
6. Redesign motion recipe: the dashboard image slides up and fades in; on scroll the hero text fades out and the dashboard fades in.
7. You don't need scroll animation to captivate: Intercom uses one section plus one hover animation that demos the product.
8. **Break the pattern once:** where users expect the animation to end, fade out the rest of the UI and bring in short feature text. That beats the default "image left, text right" without adding much movement. Examples: a hover with a screen-like background effect; Iceberg Dock's "Explore the project", which unfolds a whole page.
9. Linear's menu: **alignment and type differences alone** show what's clickable, what's a label and what's a keyboard shortcut. A click opens an expanding modal as a small reward.
10. On mobile, onboarding is the place to captivate (Craft). **Direction carries meaning:** sliding up from the bottom = a temporary action (a tool tray); sliding in sideways = progress through onboarding.

### 20. How to think like a GENIUS UI/UX designer (HE4rLEQpiXY)
1. **Start from user intent, not visuals.** For a rental flow the intent is searching, so start with a search bar (destination, number of travellers, dates). **Roast:** adding a header and a background image "does nothing extra" for function.
2. A second intent (browsing without a destination) gets listings plus filters. Add functionality only as intent grows; fonts, colours and icons change the look, not the function.
3. **Respect 30+ years of conventions:** information flows top to bottom and left to right, navigation sits at the top, CTAs are eye-catching and easy to find. Layouts that follow them take new sections and responsive changes more easily. Set yourself apart with a micro-interaction or a unique feature, not a broken layout.
4. **Card content = what users scan:** location, rating and price first. Drop the per-card description, since the detail page carries it.
5. **Stress-test with ugly content:** truncate long names (ellipsis), and put a **circle behind the save icon** so it keeps contrast on bright photos. "Perfect content" mockups hide bugs.
6. **Roast (his own old portfolio):** animations that "didn't do anything". An animation must add clarity or function.
7. Progressive disclosure examples: when links overflow, fold them into a menu that animates in. When a web app turns browse-first, shrink the search bar and expand it on click instead of keeping a sticky search block.
8. **"Load more" button over infinite scroll**: it gives control and keeps the footer reachable.
9. Buttons should **almost always** have a small animation. Scrolljacking: "very sparingly, if ever."
10. Size the design system to the team: a lean startup needs a light, disposable one; Material is huge because it serves billions of users. Writing the rules (spacing, type scale, interaction patterns) matters more than the artifact. Break the system on purpose, never by accident.

### 21. 7 UI/UX mistakes that SCREAM you're a beginner (AH_ugxmLeUM)
1. **Flow gaps.** An allergy screen with 6 presets but **no search and no skip** → add a search field and a Skip button. Sketch boxes on paper first. The most commonly missed pieces are nav links, hidden states, and hover and micro-interaction states. Small additions that help: a filter icon inside the search bar, a save button at the top.
2. **Gradients:** a blue-to-green gradient → if you must use one, use variations of **one hue** (darker or lighter green). Usually better: no gradient.
3. **Shadows:** Figma's default drop shadow is too harsh. Don't just lower its opacity: **change the shadow colour to a light grey and raise the blur a lot**, or remove it. Less visual noise is better.
4. **Spacing:** beginner UIs are packed too tight. Put the screens on a **3-column grid** and a **2-column grid** *(margins and gutters on screen only)*, align everything to it, and allow small breaks if it still feels balanced. Increase vertical spacing in stacks; mobile needs "more space than you think". Use auto layout with **vertical trim off** for pixel control.
5. **Inconsistent components:** mixed corner radii, and a Back and a Skip button that do the same job but are drawn differently. Fix: make both search bars identical except for the placeholder, give **all small components a 10px radius**, and match the Back and Skip buttons in size, radius and style. Use colour styles, variables for measurements, and components.
6. **Icons:** cards without icons force reading → add icons and replace the "Save" text with an icon. Mixed fill, stroke width and style → use **one library** (Flaticon: interface icons, filtered by stroke, weight and corner, downloaded as SVG; Figma plugins: Feather, Phosphor). Known icons (home, bookmark, user) need no label; obscure ones get a tooltip. Different icon styles are OK **only in visually separate areas with different jobs** (navbar vs food tags vs recipe meta).
7. **Redundant elements:** remove carousel arrows when the user can swipe on mobile; remove decorative arrows inside buttons and dim the button colour; remove strokes on cards (or dim them a lot if contrast worries you).
8. **Missing feedback:** if the next screen loads late, the click looks ignored → **grey the button out on press**, and add a spinner if it takes long. Save: fill the icon **and** put a red dot on the Saved tab.
9. **Charts (bonus roast):** the Dribbble chart has no y-axis, rounded bar tops (you can't tell where the value ends) and **16 bars for 7 days**. Replace with a plain chart: an axis, square bar tops, one bar per data point. Less pretty, far more readable.

### 22. Vibe Coding a Pro UI in SECONDS With AI (xHD01_Onac0)
1. Reference images: **Dribbble dashboards are too detailed**; Claude drops the small details and misses the point. Use realistic product screenshots instead (siteinspire.com, Linear).
2. 21st.dev: a library of components built with or for AI; copy the component's prompt or code into the LLM.
3. **Prompt recipe:** (a) say explicitly that you want a *design*, and ask for **HTML and CSS** (needed for the Figma import); (b) give the purpose and use ("project management dashboard to track ongoing projects and see tasks"); (c) name the elements you need (a sidebar with icons, a Gantt chart with colourful bars); (d) **tell it to use an icon library**, or it falls back to emojis.
4. Figma import: the html.to.design plugin → File tab → Claude's "Download as HTML" → defaults, but turn **hover effects on**.
5. **His post-AI fix list (the usual AI dashboard flaws): fonts, alignment, colour.** Specifically: the top line sat too low; the sidebar top should show the user's name and avatar with an arrow to switch accounts; menu items aligned; group labels ("Menu", "Other") removed; Settings and Help Center moved to the sidebar bottom; purples pushed toward blue; backgrounds darker and **purple-grey rather than bluish**; chip contrast fixed; a subtle grid pattern added.
6. **Semantic colour consistency:** if one colour means "completed", don't paint uncompleted rectangles in it. Replace a vague "In progress" label with an **actual percentage**.

### 23. 11 Micro Animations That Will Instantly Level Up Your UI (ld1zhQMXxXU)
1. **Button hover:** a mask holding two copies of the label, so the text slides up on hover. On press the button **scales slightly smaller**. Variants slide horizontally or diagonally. This saves inventing hover colours at the last minute.
2. **Keyboard shortcut hints** (Rainbow Wallet): keycaps animate as you press them, with a success message when the whole combo is pressed.
3. **Toasts** (Vercel, Linear; he prefers Linear's): slide up; can contain a loading animation and turn into a celebratory success state with particles.
4. **Name tag on avatar hover** (Huddle): a pill (auto layout, full radius, black fill, white text, slight tilt). Initial state: the same tag shifted down a bit at opacity 0. **Spring: 500ms, stiffness 636, damping 24.**
5. **Shimmer / gradient stroke:** a stroke outline made by subtracting two rectangles, masked over a circle with a rotating angular gradient. It moves faster on the long edges, so he adds a **pause/play toggle**.
6. **Delayed tooltips** (Obsidian): show on mouse-enter after a **1000ms delay**, hide on mouse-leave, with a slightly bouncy easing *(curve on screen only)*. Use when you have many icons and no room for labels.
7. **Text-hover pop-out** (Figma Community, Ace Studio): hovering a word pops out an image of it, showing the thing without more copy or space. His favourite.
8. **Progress bar** (Linear forms): a stroke masked onto a sliding rectangle so it "draws" around the step circles; everything else fades.
9. **Card-stack swipe** (dub.co): stacked cards; the top one rotates away to opacity 0 while the ones behind scale up and shift down. Key detail: **while dragging, the other cards move in to fill the gap.** Suggested placement: a bottom-right notification centre.
10. **Search expansion** (Apple): a magnifier icon expands into the field on click (3 frames, a click, then a delay); the magnifier "disappears into the circle".
11. **Upgrade details on hover** (Dub): show the Pro limits on hover. He rejects strikethrough of the old value; instead **slide in the new value and remove the old ("20")**.

### 24. Animated Dashboard Sidebar Tutorial in Figma (NtZeYmTMuo4)
1. "Icons are the secret to a great sidebar."
2. A **very subtle outline** on cards and nearly every element lets the palette stay tiny: mostly pure white or near-white.
3. Pop-up drop shadow: **very light grey colour, not transparent black** *(exact values on screen only)*.
4. Nav hover: a rectangle behind the label fades 0→100% opacity ("while hovering" + smart animate). Animate **layer** opacity, not fill opacity.
5. Dropdown menu entrance: fade in **plus a few px of upward slide** (start a couple of px lower).
6. Smart Animate pairs layers **by name**. Give a rectangle the same name as the search bar and it morphs into it; different names cross-fade. (Equivalent in code: give shared elements the same key or layout ID.)
7. Integration tile hover: a label slides down and fades in; the tile background turns slightly off-white.
8. **Selected/focus state:** a bright yellow stroke at heavier weight, plus a duplicate layer with a **24px layer blur** behind it as a glow.
9. "Connect" hover: a link icon scales up from small at 0 opacity next to the text, pushing the text over.
10. **Spinner:** 4 frames with the icon alternating 0°/180°, chained "after delay" at **300ms**, with a **custom spring of stiffness 550, damping 40, default mass**. Success state: the yellow stroke becomes black, and a check mark **slides in through a mask** (not a fade) after **300ms, ease-out**.

### 25. The 8 UI/UX Cheat Codes for INSTANTLY Better Designs (c1TvOcKdBVE)
1. **Kerning on large text:** above roughly **70-80px**, auto spacing looks disjointed, so tighten letter-spacing by eye *(his value on screen only; standard practice is negative tracking, about -1% to -4%)*. Don't blame the font.
2. **Nested radii:** inner radius = outer radius − gap (**30px outer, 10px gap → 20px inner**). It breaks when the gap ≥ the outer radius (then eyeball it). Pills are exempt.
3. **Smoother corners:** Figma's iOS corner smoothing at max (squircle-style).
4. **HSB palette recipe:** start with a base (Coolors). Each darker step: **saturation +20, brightness −10**. Better version: also shift **hue about 20 toward blue** on each darker step (blues and purples read darkest, yellows and reds lightest).
5. **Card layout (rental listing):** delete field labels ("if your UI isn't clear enough to imply these labels…"). Group like data (name + location, price + rating, specs, check-in/out) and rank it. Stack name and location on the left with **price and rating right-aligned**; put specs in one row **with icons**; give check-in/out its own row and **keep their labels** so they don't get mixed up.
6. **Lose the lines:** separate list items with space. If they must be tight, use **subtle alternating row backgrounds** instead of dividers. Exception: sites whose style is lines.
7. **Spacing grid:** a 4px or 8px base. In Figma set the nudge amount from **10 to 8**. For large values round to the **nearest 5 or 10**, or if you stay on 8, step up exponentially; **120 vs 128 makes no difference.**
8. **Tinted backgrounds, not pure white or black:** GitHub uses very dark blue; Studio Rubric uses very light orange. Tailwind shortcut: **light mode = bg `{hue}-50` + accent `{hue}-500`; dark mode = bg `{hue}-950` + primary `{hue}-300`.**
9. **Dark-mode depth without shadows:** each raised layer = background with **brightness +4 to 6, saturation −10 to 20** (HSB), repeated per layer.

### 26. Redesigning A Modern Skincare UI from SCRATCH (BvbFPzLjWcU)
1. Domain look: skincare = **great product photos, a bright white background, lots of white space**.
2. **Roasts of the Dribbble original:** social links in the header; a page-outline nav on a site too short to need one; an image with cutouts; a **written testimonial in the hero**; decorative blob shapes; "free shipping over $500".
3. **Real viewport: 1920px wide but only about 1000px tall** once the browser bar is counted. Dribbble shots cheat with frames about 50% taller. Squeeze the hero to fit about 1920×1000.
4. Layout: an ultrawide split into two halves (image and text left, products right), common on modern beauty sites.
5. Nav: **logo centred**; favourites and notifications folded into a menu button; cart → an icon; profile → "Sign in"; a search bar added to balance the bar.
6. Products in a **slider** with a cute "New arrivals" chip.
7. Hero photo: a **subtle overlay** for text contrast. **One serif (New York) across logo, packaging and site.**
8. Subtext plus a **primary and a secondary CTA**; he admits the arrow-only round button is purely aesthetic.
9. Packaging: real beauty packaging carries too much text; go minimal.

### 27. 7 Modern UI Layouts from 50 Top Software Companies (VPeTgU7la34)
1. **Logo wall:** on 41 of 50 SaaS sites. Simple version: the top logos in one row. Fancy version: a **marquee sliding across, with a gradient fade and a progressive blur at the edges**.
2. **"Versus competitors" section** (Coda via a testimonial; Basecamp bluntly).
3. **Centered hero:** big text, big image, lots of space; used by about 30 of the 50 listed (Dropbox, Monday, GitHub, ClickUp, Miro, Intercom, Mercury…). Stand out with a distinctive font and an inline diagram, or make it interactive (ClickUp). A **very subtle background gradient** keeps it from going bland.
4. **"Clickable multi-section"** (tabs that swap a content panel): Miro uses it 4 times on one page; Webflow auto-advances on a timer; MongoDB keeps it simple. **Design every tab**, never only the first.
5. Animations: simple and tasteful (Pipe, Klaviyo), "make them simple and make them well". **Roast:** Coda's third-party scroll animation renders **blurry**; GPU-melting graphics.
6. **"Simple bento"** (Butter, Kit, Ramp with one slightly tilted card) instead of Apple-style marketing bentos: simple grids devs can build.
7. **"Straight-line grid"** (Vercel, Catalog): content sits in visible ruled grid cells, not floating.
8. **Images in nav dropdowns** (Intercom's mega menu, Pipe's small one): previews beat lists of links. His pick for the trend most likely to stick.

### 28. 20 Top Underrated Web Design Resources for 2025 (eeN7yUcIWbw)
See section 4.6 for the full list. Takeaway for a skill: point agents at curated section libraries (Unsectioned, Relume kit), micro-interaction galleries (Design Spells), placeholder logos (Logo Ipsum) and mesh-gradient tools instead of inventing assets.

### 29. I Redesigned Spotify Wrapped Entirely From SCRATCH (goWOAFqJHpA)
1. **Roast:** the click-through story format is the worst way to look up stats at a glance. Apple Music offers both a highlight reel and a dashboard. Don't throw out a format users have known for about 8 years; borrow **Reddit Recap's vertical scroll** instead of tap-through.
2. Navigation moves to the **right edge and doubles as the video progress bar**.
3. **Put the important controls at the bottom** (thumb reach), not the top. The **share button is always visible** at the bottom (sharing is why Wrapped succeeds), and tapping it **pauses** the video.
4. **Remove the pause button:** the Gen-Z audience knows tap-to-pause. Keep X at top; move volume to the bottom.
5. **Chapters** in a dropdown chip at the bottom for skipping; each chapter ends with a **"View summary" dashboard** screen that shows the stats and can be shared without leaving the format.
6. **Roast:** hyper-specific AI-generated genre names; users want a few recognisable categories. Bring back top genres and Audio Aura (and compare auras year on year).
7. Personal data hooks: most-skipped song, late-night anthem, year-on-year change ("120% increase", "you two just met in April"), rising star, obsession ("87% of streams from one track"), month-by-month swipe.
8. Avoid two share buttons (confusing). **Use one share button with three options: slide / chapter / whole Wrapped.** The shared view shows the owner's name at the top.

### 30. 7 UI Design Trends that are CRIMINALLY slept on (EHwZzWd-OnQ)
1. **Text swapping:** two related phrases alternate in the same spot as you scroll (cheap interactivity).
2. **Hand-drawn accents:** pencil-tool circles, underlines and arrows against **bold, clean type**; the contrast is the point.
3. **Distinctive display fonts:** inspect a site → Sources → fonts (mind the licences).
4. **Animated type** as a storytelling element, not plain paragraphs.
5. **Line dividers are back**, used as a deliberate style (Isomorphic Labs; lines can have rounded corners). Caveat: done badly they look like an old PowerPoint.
6. **Morphing images/videos** (We Are Motto, Kiara Hoffer's entrance). Keep the changes small or the browser janks.
7. **Scroll-driven explainer diagrams** (Develop Medicines' process); simpler: 1nil's diagram, where hovering rotates the item and blurs the others.
8. **Images in menus** (Rivian: thumbnails show the R1T is a truck and the R1S an SUV), "like a Chinese restaurant menu with photos".

### 31. 6 Things You Probably Need to Hear (6CC8lLnqa28)
1. **Roast (his early self):** only white, grey and one super-saturated blue, picked from the **top-right corner of the hex picker**. Explore desaturated and unusual colours: take 1-2 from an online generator's 15 suggestions, or pull them from nature and artwork.
2. **One CTA (maybe two) and one main thing in the hero**, like Google and Apple. You don't have to fill the screen.
3. Simple sites convert: Toah HQ (invoicing), Linear (dark mode plus a little glassmorphism, nothing crazy), Huddle. **Scrollytelling (Prometheus Fuels) suits awareness, not conversion.**
4. Drop effects that slow loading or make navigation harder.
5. Make a mood board (Dribbble, Behance) before opening Figma; a "sliver of an idea" stalls.
6. Ask honestly: "would I hire me?"

### 32. 5 Trendy Animations to Steal (ZsP20PN14O0)
1. The five types: **entrance, hover/click, scroll, looped, mouse.** Beginners go too big; keep them subtle.
2. **Preloader:** slides up; **also move the content under it and nudge the background image/video**. Without that it looks flat. Good for covering heavy hero video or 3D loads (Fabric, 1nil's simple fade). **Keep it short.**
3. **Button hover:** a masked container; the label slides up while a circle and new label slide up; the button scales; the circle's radius shrinks toward a rectangle (Quite Nice does something similar).
4. **Highlight-on-scroll text:** a gradient with two colour stops almost touching, the text used as a mask, the gradient translated with scroll position; straight or diagonal; lines in sync or staggered (Planhat).
5. **Looped animations must be minimal and slow** (an icon on a semicircle path drawing its trail; a slow vertical marquee you can still read). Complex loops distract and annoy.
6. **Mouse-follow:** best use is a CTA that follows the cursor; centre a container on the cursor with easing. Use sparingly and **always give tablet/mobile a fallback** (no hover there).

### 33. How hard is it to make a no-code 3D animated website? (A_Ozpb0XDuw)
1. Pipeline: Figma logo SVG → import into Spline or Blender → extrude → camera, lights, material → export video → place in Wix Studio.
2. **Spline:** Figma-like UI, quick, but **video export needs a paid plan**. **Blender:** free industry standard; a steeper curve but nicer metallic materials.
3. A strong 3D centrepiece (spinning logo plus a marquee of text under it) carries the page, "you don't need to do that much designing". Watch the lighting for dark spots during rotation. About 2 hours per asset for a first-timer.

### 34. I spent a week gamifying apps (jSxxAFxjxbU)
1. **Five gamification principles:** (a) a **central currency** (Duolingo XP, Todoist Karma) that shows progress and unlocks features; (b) **progress visibility**, showing done vs remaining (Exercism %); (c) **social** features (Strava leaderboards, public badges); (d) **meaningful rewards tied to real goals**; (e) **completion drive** (LinkedIn's profile-strength meter; credit-card points).
2. **Duolingo model:** two activities (lessons, challenges) → XP (can't be spent; ranks you and unlocks daily quest chests) → gems (second currency, buy extra time or hearts) → hearts lost on wrong answers (punishment) → daily streak → milestone achievements that pay gems.
3. **Finbase design:** "fin bits" earned per saving and per completed goal (scaled by goal size); streaks; a **local leaderboard so currency and income differences don't skew rank**; virtual sub-accounts for goals on one real savings account; education lessons with a quiz that pays currency; badges (for example 30 days of saving in a row).
4. **Show the value before gamifying:** onboarding gives swipeable insights from past spending (category breakdown, average per month) before asking for a goal (amount plus a **time-period slider**). Reassure people at the bank-connect step.
5. **League leaderboard:** promotion zone, safe middle, demotion zone back to "Stone"; the next league shows as "?" (undiscovered).
6. **Analytics:** a saving/spending toggle plus daily/weekly/monthly; a spending-target line with **overspend bars in a distinct colour**; recent transactions; insights on upcoming bills.
7. Process honesty: 4 screens took 3 days; he switched the whole app to dark mode on day 2 after reviewing it.

### 35. TikTok's UX is so GOOD it should be ILLEGAL (ixUq4HM4FNg)
1. **Remove options rather than limit them:** TikTok's main interaction is swipe up, with near-zero decisions and lower cognitive load (the remote-with-taped-buttons analogy).
2. **Target size and distance:** the swipe target is almost the whole screen and the thumb barely moves. He calls this Hick's law, but it is **Fitts's law** (see section 5).
3. **Action icons on the right edge** for the 70-80% who are right-handed, a bottom nav, almost nothing outside the thumb's easy zone; auto-snap and autoplay.
4. Onboarding: pick interests, "the shortest tutorial ever", then learn from behaviour. **Only 30-50% of the first 1000 videos** come from onboarding picks.
5. **User feedback on the creator side:** likes, comments and shares arrive fast; short format makes going viral possible for newcomers. Free tooling (CapCut) feeds the supply.
6. Numbers: an average TikTok is 37s vs 11.7 min on YouTube (about 19× shorter); 53 min a day ≈ 80+ videos; opened about 8×/day.

### 36. I Redesigned a Failing Tesla WANNABE Full Website (V3Omp1hm0Sg)
1. **Roasts (Fisker):** a homepage with nothing on it; sticky sideways text that follows the scroll (distracting); **too much white space plus giant text = disjointed**; spec text far smaller further down, so the page reads as **two different styles**; the page far too long.
2. **Fix by proximity:** push related elements closer together so hierarchy forms and nothing floats alone.
3. **Roast (EV sites generally):** stacked full-screen images copied from Tesla are "lazy". Rivian is his favourite (images in the nav).
4. **Structure: one product → no homepage.** Lead with the product; link the other pages in the nav; add mission and blog sections at the bottom.
5. **Hero image:** search Google Images with Tools → Size: Large. Pick a **zoomed-out** shot (a subject that's too big "punches you in the face"). **Never put text over the focal point.** Text-behind-subject effect: trace the car's outline and subtract it from the headline. The zoomed-out frame also leaves room for a **specs info bar** in the hero (moving stats up from far below).
6. Replace the side-rail logo with a normal top-left logo; collapse links into a hamburger.
7. **CTA cards:** **Roast:** one image with a background and one without (disjointed), an eye-straining colour combo, the whole page dark. **Fix:** titles above the images (no contrast problem), consistent tasteful images, and a hover that **zooms the image out and reveals the CTA**. The **bright orange appears only on hover** so it never overpowers.
8. **Feature sections:** too spread out and the type-size jump too large → shrink the text and use a **slider** (Lucid). A second section identical in layout → turn it into a **bento** ("variety in layout is a must"). Nobody reads accordions; they look at pictures.
9. Colour pick: sample the background gradient **from the image above**. To extend a sky, duplicate the image, flip it vertically and crop.
10. **Trim levels:** tabs → side-by-side columns with photo and specs. Long spec text goes behind **"See more"** and slides up on hover. When the trim images are weak, tuck them behind the next section.
11. Add-on package: per-model buttons open a **lightbox card** (full-size photo, text overlay on a gradient, an X close). Final CTA = a **dealer search bar** instead of a button. Blog rows: images right, a different heading font, and **flip the middle row** when everything lines up too neatly. Footer with many links: just keep the original.


### 37. I Made The Most UNHINGED UI Upgrades (downgrades?) — BUDipdbKK7Y
This is satire: he designs deliberately hostile features. The design lessons come from turning each one around.
- Copy that shames or guilts the user ("342 videos is a lot") and is tied to an upsell enrages people. Never put judgement in system copy.
- A modal that blocks all other work until a chore is done (his forced Figma layer-naming) is the textbook infuriating pattern. Make the action inline and skippable.
- Even when a feature is annoying, he keeps "good UX": a visible notice telling the user how to turn it off. Every opt-in behaviour, and every behaviour that could annoy, needs an obvious off switch at the point where it shows up.
- Goal nudges must be achievable. A "you'd need to run a marathon today" goal message demotivates. If you suggest changing the goal, keep the tone neutral.
- A randomized action is useless unless it is grounded in the user's data (for example past orders) and shows its consequence (a cart total against a budget).
- Don't gate trivial content (a recipe) behind a paywall or account wall. He calls this maddening even on finance sites.
- Shared control of a user's devices or orders (pay-for-the-next-person, neighbour-controlled lights) must be off by default and controllable in settings.

### 38. I Redesigned Google's AI Website from SCRATCH — pGYLZyBE32o
- Roasts: OpenAI's site is "lopsided" with a boring layout; Microsoft has too many tabs and videos nobody watches, plus tiny blog text; Gemini looks neglected next to Chrome's page.
- Hero CTA: use a real text input ("ask Gemini…") instead of a plain button. Typing sends the user to login, but the user is already engaged in an action and more likely to finish it. It also looks better than a button.
- Brand colours applied to headline text "looked off". He used the Google logo on a white background as a mark, plus the product glyph (Gemini star) above the headline. Use a logo or symbol, not multi-colour headline text.
- Background shapes looked messy against a clean brand. He put the product's own "AI thinking" loading animation into the bottom of the hero instead. Borrow motion from the product itself.
- Bento section: drop the section title if the cards already say it ("seems kind of redundant"). Use the product's real UI diagrams inside the cards. Search Google for existing brand assets before inventing visuals.
- Dark-mode colour trick: give the background a gradient between two primary brand colours (Gemini baby blue and pink), then drag both colours down in brightness until they are dark. Add noise optionally, but not so much it "looks like TV static".
- Consolidate redundant landing pages. Gemini Advanced and Gemini for Business sold the same thing, so he merged them into one section built on three points: cost, a better AI, and uploading Docs, Sheets and PDFs.
- Hover cards: on hover, blur the image, scale it up and reveal extra text (credited to Accenture). Make the purchase CTA one of the cards and give it a gradient stroke.
- Content only about 2% of visitors need (Enterprise) becomes a tiny button on every plan card, not a section.
- Feature cards: replace multi-colour gradient icons with one brand blue on a bluish-grey gradient background, with a brand-gradient stroke on hover. Icon source: search Flaticon filtered to "interface icons" for clean, simple ones.
- Don't reuse the same layout for two sections on one page. He rejected a blog layout because the "explore" section already used it. He iterated the CTA through four layouts (prompt cards with input, then input under text, then input only, then centred with decorative cards moved to the sides and given a gradient).
- Footer mirrors the header (logo plus the same nav), swapping the logo variant.

### 39. Redesigning a Finance Dashboard UI from SCRATCH (ft. Dribbble) — Yr2uIcFZDDQ
- Typical Dribbble work "looks amazing but doesn't make sense once you zoom in". Check that every control is logically possible in the domain.
- Fold check: if the important content will fall below the fold, don't spend the top band on a header. He moved the header contents into a sidebar.
- Delete labels that state the obvious ("Financial dashboard"), duplicate controls (two search bars become one), and features nobody uses in the domain (voice dictation in finance).
- A button that only opens a list ("tasks") should become a visible section. Don't hide primary data behind a click.
- Sidebar order: logo, menu, team (with a "manage team" button), settings pinned at the bottom. The "add widget" action goes in the sidebar. Design a collapsed sidebar state as well.
- Merge cards: 12 widgets were too many. The system lock goes into the credit-card widget; growth rate and its chart go into the annual-profits card. Delete cards with no clear meaning ("13 days") and bulky low-value ones (a questionnaire).
- Domain logic: a credit card can't "receive" money or take direct deposits, so remove those buttons and add "Lock card". Replace "monthly fee" with minimum payment plus due date. Add pagination to scroll through multiple cards. Card visual: realistic (Wise-style) with the brand logo blown up at low opacity as texture.
- Layout: the more important a module, the higher and further left it goes. Rank modules high, mid and low first, then place them. Choose the orientation that leaves no awkward gap. Fill a leftover gap with a module the domain genuinely lacks (he added a line-of-credit pie chart).
- Charts: numbers without labels "don't mean anything". A chart next to growth percentages that show the same thing is repetitive, so remove the chart and show percentage chips per level. Line charts get no curve smoothing ("bad") and no fade on the data line ("worse"). Add gridlines and a time-scale selector (a dropdown when space is tight), a Compare button and a full-screen icon.
- A meaningless "minimize" icon becomes an "All activities" button. A pretty but useless diagram, or tiny-dot navigation, becomes a real alert: a fraud alert with a warning icon, amount, date and place. A vague "business plan" becomes a loan approval showing amount and repayment date.
- Tasks module: wide and thin. Show 2 cards, not 4, to keep the margins consistent with other modules. Add filters, a primary "All tasks" button and an add button beside it. This is the call to action, so it is high priority.
- Income vs expenses: a two-sided bar chart, with bars up for income and down for expenses. Title it "Revenue and expenses", show the dollar values and add a full-screen icon.
- Secondary detail (interest payment) goes behind a kebab menu rather than on the card. "Data representation… will make or break" a dashboard.

### 40. Upgrading 9 CRUCIAL UI Elements — gKM6b2EnW1k
- Mobile tab bar: remove the raised, circled centre "+" button. Users use every other tab more, so drop it into line with the others. Line up the icons. Inactive icons must still be clearly visible, because the active state already marks the active tab. Give the "+" an active state by swapping its icon. Use the profile photo for the user tab when one exists. Brand colour belongs on the active state. Widen icon spacing slightly to grow the tap area. Add labels when icons are obscure (Apple Music has them, Instagram doesn't), and make the labels dark enough to read. Dark tab bar can use transparency plus blur.
- Background colours with no contrast are pointless: "the whole point of using colors is that you can see them."
- Charts: add horizontal gridlines and markers. Turn off line curving, because it hides where the tip actually is. Don't fade the most recent data. Add vertical gridlines for the time scale, time-frame switching (tabs, or a dropdown if short on space), a grey previous-period line for business metrics, and a legend.
- Content cards: tighten image and text margins, make paragraph text slightly smaller, use a modern font and round the corners. Repeated cards need no CTA button; the whole card is the link, signalled by an arrow icon fading in on hover. Keep an explicit CTA only for specific actions ("Try it out"). Fancy variant: image about 3/4 of the card height with a smooth gradient overlay from the image bottom upward, text on top. It only works with some images; the plain card always works.
- Pricing card: move the button up under the price, then fix the hierarchy by making it stroke-only (no fill). Replace bullets with check marks and add a crossed-out feature the plan lacks. Give the plan a name and a one-line description. Add a note for the billing truth (for example the monthly equivalent of $20/month). Separate price from features with a tinted block (primary colour at reduced opacity), not a divider line. Make the CTA copy actionable.
- Stickers (breaking boxy layouts): Figma star tool with 12 points, ratio dragged and corners rounded. Use a quirky display font, an optional outline or circular text (the "Text to Path" plugin), and a drop shadow in a darker shade of the sticker colour at full opacity, offset, with no blur implied.
- Sign-up modal: never use labels as placeholders, because the user forgets what the field is mid-typing. Put labels above the inputs, always visible, and use placeholders for example values. Add a "Create account" subheading so it can't be mistaken for login, plus a "Log in" link. Add spacing; he sticks to a 4px grid "religiously". Inputs: off-white fill with the stroke at 40% opacity.
- Footer: don't copy Apple's or Linear's 5-column footer when you have 3–5 links. Centre the links, put the logo above and socials below, the copyright on the left and the credits on the right. It also works in dark mode.
- Chips vs buttons: too small looks stupid, too large becomes a button. Chips almost never use the primary CTA colour and are always vertically thinner. Use auto layout (Shift+A). Vertical padding is 1/2 or 1/4 of the horizontal padding (20px horizontal gives 10px or 5px vertical). Chips suit breadcrumbs and filters.
- Carousel: add position indicators so users know how many images there are, on a dark blurred pill over the image (or below it). Put the arrows beside the indicators. Optional: the active dot extends into a progress timer bar.

### 41. Mathematically Perfect Typography for Web Design — 7sUUzOCv47U
- Font count: 1 is fine, 2 is the max for most sites, 3 is "pushing the envelope", 4 is "asking for problems". With 1 font, use a sans. With 2: display plus sans (most modern sites), or sans plus serif, or handwritten in place of display. With 3 (his portfolio): display (Fola One) plus sans (Axa Forma) plus mono for captions (Courier Prime).
- Never use a display or handwritten font for small paragraph text ("100% a design sin").
- Letter spacing scales inversely with size: large text gets proportionally less tracking, small text proportionally more.
- Weight and colour are interchangeable for hierarchy at small sizes, because fewer dark pixels read the same either way. Avoid ultra-bold and ultra-thin for regular text. Use two text colours: 100% opacity and somewhere between 40% and 70%.
- Hierarchy recipe, correcting the predictable one: don't make the heading bold, the subheading normal and the paragraph light. The smallest text ends up with the least contrast, which is unusable. Instead the heading is large (size already wins, so keep it regular weight and 100%), the paragraph stays at 100% opacity, and the subheading goes bold so it scans.
- Golden ratio 1.618 (he rounds it to 1.62): one heading for body text is body × 1.62. As a full scale from 16px it grows too fast (16, 26, 42, 68, 110px). Use √φ ≈ 1.27 as the default step (16, 20.4, 25.9, 32.9, 41.9, 53.3px). Use ∛φ ≈ 1.17 (16, 18.8, 22.1, 25.9, 30.4px) for dense UIs such as dashboards, or for mobile.
- Fluid type with no breakpoints, in one CSS line: `font-size: min(max(MIN, calc(MIN + (MAX − MIN) × ((100vw − 320px) / (1920 − 320)))), MAX)`. He uses 320px as the smallest width and 1920px as the largest. max() enforces the lower bound and min() enforces the upper bound. The modern equivalent is `clamp(MIN, calc(MIN + (MAX−MIN) * ((100vw − 320px) / 1600)), MAX)`.
- Line height: smaller text or longer lines get more line height, larger text gets less. Body is about 150%; headings are 110–130%. Don't leave line height on auto for very large text.
- Always check type on the actual target screen.
- (Analysis-file error: the Video.md says subheadings use 40–70% opacity. The transcript says subheadings go bold and paragraphs stay at 100%.)

### 42. Make ONE Design Change to Actually Land Clients — 5JxUJ1fuyO8
- Clients judge mostly the UI; end users judge function. Results come from UX. For a catalogue with hundreds of products, the fix is refined search plus recategorization, not a prettier page.
- ClickFunnels-style test: is all the information laid out clearly, and does the user know where to click next? Those two questions beat beauty.
- Pick the content blocks that serve the business goal: testimonials on an agency homepage, impact stats ("what we did last year") for a nonprofit.
- Prove results with before/after analytics. Problem, solution, numbers.
- The aesthetic-usability effect is real: good-looking designs are perceived as easier to use. Aim for both.

### 43. Awful To AMAZING Web Designs Easily — ulSOdTgoGeY
- Roast: a "well-made but boring" site that repeats the same image-left/text-right column row down the page. Mix layouts: a full-screen section, cards, a 3-column row (Shopify is his example).
- Break the box: overlap elements across section boundaries, shift cards up and down in a row for a sense of movement, and let a card row extend past the frame edge as a slider.
- Images: cut out the background of a single-object photo (it focuses attention and breaks the box). Crop and zoom into part of a product photo (Apple). Put an overlay plus text on a wide landscape shot for a brand-message section. Mask images into shapes that match the site style.
- Size creates variety and attention: make one element much bigger. Stack a 2-column feature row into a 1-column vertical sequence so only one feature is in focus at a time (Apple).
- Depth: an offset duplicate of a button or card behind it, which animates on hover. Use sections with tinted backgrounds. In dark mode, a darker background recedes behind lighter cards.
- Dark mode is not inversion. Flip text to white and lighten or desaturate the primary and accent colours, which are "far too saturated" on dark (the blue becomes a lighter blue). Frosted glass on cards and on the blue background.
- Replace plain white backgrounds with off-whites, or a subtle image background with a noise overlay.
- Motion: slow photo zoom in or out ("classy and very easy"), accordions, marquee text (warn about its reduced usability). Portfolio redo: centred text, a larger name, stats rearranged, and phone screens that slide up staggered on load.

### 44. 8 Web Design Hacks To ACTUALLY Make Your Designs Better — Lp6ey4AyDzA
- Hierarchy has three tools: size, weight and colour. Most people use only size. Use at most 2 weights, separated by at least one step (for example 400 and 600, not 400 and 500). Use at most 2 text colours: primary plus the same colour at 45–70% opacity.
- More space, fewer containers, fewer lines. Cards and dividers make even sparse layouts feel cluttered and take more footprint, especially in multi-column grids like e-commerce. Remove them and let spacing do the grouping (proximity).
- Icons: use one consistent style from one pack (his go-to is Feather). Keep them simple. Detail scales with size: large icons may carry more detail, small icons less. Check the intended size.
- Muted colours (baby blue, beige, lavender) beat all-or-nothing saturated colours. Use off-white for light mode and bluish-black for dark mode; it marks an experienced designer.
- Not every button needs a background. A hero has only one primary CTA. Delete the second, or make it backgroundless. In a delete dialog, Delete is the primary action even though it is destructive: filled red. Cancel gets no background, just a border or reduced opacity.
- Text as a visual element: giant display type (Unbounded, Cabinet Grotesk, and one he calls "Gourd Quick", spelling unconfirmed; find more in Google Fonts with the display filter). Use it once, at most twice, per page.
- Gradients and drop shadows: if they aren't working, remove them. "Any good website with a gradient can be a good website without." Shadow formula: x ≤ y, blur 1.3–2× y, opacity 15–20% (down from Figma's 25% default). Darker backgrounds need a stronger shadow.
- View designs on the target device (zoomed-out Figma led him to oversized fonts and spacing). Account for the browser bar on both mobile and desktop.

### 45. Advanced FIGMA Web Design Effects — MZSm6MA8bww
- Kaleidoscope (cards, stickers, buttons): a radial gradient circle, then an angular gradient alternating black and white an even number of times (8; 6 or 10 also work) set to blend mode Difference. Duplicate that layer, set it to Screen, and keep it on top. Add noise, plus thick text set to Overlay. He admits its usability is poor, so keep it decorative.
- Clay (isometrics, illustrations): a muted, low-saturation fill, because saturated colours fail. One inner shadow covers the top and right edges and a second covers the bottom and left. An optional drop shadow. (Exact values were shown on screen only; not captured.)
- Metallic (cards, mockups): a linear gradient of greys and dark blues with a noticeable colour change in the middle. A white radial gradient layer set to Overlay. Two inner shadows. Tint layer at 20% fill: red, orange or blue gives gold, bronze or titanium.
- Mesh gradient with no plugin: a blurred, semi-transparent base circle, then more blurred, transparent circles set to Overlay. More overlapping layers make it brighter and more vibrant; use 8–10 or more. "More an art than a science."

### 46. How To Price Website Designs — 2rtsoM2Dqrs
Business only, so outside the design rules. The one transferable point: estimates run long ("things generally take longer than you think"). He also prices value-based work at 5–10% of the revenue gain.

### 47. Create A Portfolio With No Experience — 59XWYgN00nQ
- Fake projects use realistic content: "absolutely no lorem ipsum". This is a direct rule for demo data.
- Show 2–3 case studies, or 3–4 interface-only projects. Quality over count.

### 48. Make A Perfect UX Case Study In 8 Steps — t7mpEDXzjCg
- Open with a one-sentence problem statement plus a brief solution summary at the top, so readers don't have to scroll to find the answer.
- Presentation matters as much as content. Put an image or GIF every couple of paragraphs; if it doesn't look good, nobody reads it.
- Data visuals: a title on every chart, axis titles, a legend, and circles or annotations on the key points.
- Personas are data-backed. Show only the goals and frustrations relevant to the problem, and don't fuss over the name or photo.
- Keep user flows small and colour-coded by node type (his: orange for a decision, blue for a process, green for input or output).
- Show lo-fi wireframes, including messy ones, and test them with a few people before high fidelity.
- Final designs go large, with explanatory text beside them (tabs work). Don't squish many screens until the detail is invisible.
- Add a reflection: what you'd improve, what you cut, and research limits.
- Style: tell it as a story, keep it readable in 10–15 minutes, and use chapter-like titles that summarize and intrigue rather than generic ones.

### 49. Website Layouts To Make A Professional Website Design in 2024 — P2ksReDwWkE
- Cards on a dark band: rounded rectangles sitting on a dark background, packed very close together. The spacing must be exact. It can be the theme for a whole site (Huddle, TOA).
- Thin cropped photo interlude: a very wide, short photo with one profound line of text, used as a spacer between text-heavy sections. It needs a gradient under the text for legibility. Choose the image for an extreme crop.
- Giant headline hero: huge display text (he used Oswald at 290px), with the small nav placed below the giant text (which makes the text feel more important) and a big image or video below that. The size contrast between the giant text and the tiny nav is the effect. Use a high-resolution image.
- Multi-image showcase: one large image plus a scroll arrow (images optionally grow as they scroll), and add dot indicators for position and count. Plan for heavy cropping.
- Stacked sliding cards on scroll: each card slides up over the previous one, and the next card slightly cuts off the text of the current one. Good for 3–5 items in detail.
- Horizontal card carousel: suits 3–10 cards; more than 10 is cumbersome. Give it a big "next" button and make it draggable, not only tiny nav buttons.
- Bento: box sizes change once real content arrives (he split a row of 2 into 3). It needs enough content to fill a compact grid. It can be full width.
- Cutout text: uppercase letters subtracted from a big image. Choose an image with nothing important in the corner the cutout covers.
- Text-only section with whitespace: works only if the body text runs 3+ lines; otherwise there is too much empty space.

### 50. Figma Update: Everything In Under 2 Minutes — fL1X2Mw6s3w
No UI design lessons beyond tooling. The one relevant point: consistent layer naming and grouping is what lets tools match "the same element" across frames.

### 51. Professional Portfolio Breakdown — ToJiXPTNnLY
- A headshot (or video) above the fold.
- A concise intro: name plus what you do, no fluff.
- A simple architecture: 2–3 pages maximum (home and contact; about is optional), or a single page with anchor links.
- Large, full-width imagery. Text stays secondary to visuals on portfolios, because people come to see the work.
- Visual case studies: someone skimming only the images should understand the process.
- The about page carries honesty and story. Personality lines make the site memorable.

### 52. Developing Premium Load Animations (HTML, CSS & JS): Part 2 — d4MF6pdAZNw
Uses GSAP timelines. The pattern is `gsap.timeline({paused:true})`, then chained `.to()`, `.fromTo()` and `.set()` calls, then `.play()`. `expo.inOut` is the coded equivalent of the Figma custom "exponential" bezier.
- **Loader that slides up.** `.loading-screen { position:fixed; top:0; left:0; z-index:10; background:#000; width:100vw; height:100vh; display:flex; align-items:center; justify-content:center }`. Inside it, a `.logo-container { display:flex; gap:10px; justify-content:center; opacity:0 }` holding the logo image (width about 10%) and an h3 wordmark. Timeline steps:
  1. `to(logo, {opacity:1, duration:1, delay:1})`
  2. `to('.loading-screen', {yPercent:-100, duration:1.3, ease:'expo.inOut'})`
  3. `to('.header-spacer', {yPercent:0, duration:1.3, ease:'expo.inOut'}, '<')`. Before this, `gsap.set('.header-spacer', {yPercent:100})` (100% of the element's own height, not the viewport) and `gsap.set(navbar, {opacity:0})`. The `'<'` makes the content rise at the same time as the loader.
  4. `to(navbar, {opacity:1, duration:0.3})`, with no ease needed.
- **Expanding pill nav (dot, then circle, then full bar).** `.nav-container { display:flex; justify-content:space-between; align-items:center; width:100%; max-width:0 /* final 500px */; background:<color>61 /* 8-digit hex ≈38% alpha */; border-radius:100px; padding:10px 30px }`. Child groups use `display:flex; align-items:center; gap:10px`, and the logo starts at `opacity:0`. The JS reads `navHeight = gsap.getProperty('.nav-container','height')`. Timeline steps:
  1. `fromTo(nav, {scale:0}, {scale:1, duration:0.8})`
  2. `fromTo(nav, {maxWidth:navHeight}, {maxWidth:500, duration:1.3, ease:'expo.inOut'})`. Width equal to height gives a circle first.
  3. `to([menu, logo, join], {opacity:1, stagger:0.2, duration:0.6})`
  
  CSS max-width must be 0 in the start state, or the animation breaks.
- **Text wipe.** Inside the text container, `.text-wipe { position:absolute; top:10%; left:0; width:0%; height:80%; background:<text colour> }`, with the big text at `opacity:0`. Timeline steps:
  1. `to(wipe, {width:'100%', duration:1, ease:'expo.inOut'})`
  2. `set(bigText, {opacity:1})`
  3. `set(wipe, {right:0, left:'auto'})`. This re-anchors the bar to the right; you sometimes need `left:auto` as well.
  4. `to(wipe, {width:'0%', duration:1, ease:'expo.inOut'})`
  
  The bar grows left to right, the text appears underneath, then the bar retracts toward the right.
- Expect to tune the timings by eye after coding.

### 53. Prototyping Professional Load Animations in Figma: Part 1 — nl8OFGdx75w
- Loader: a black full-frame rectangle with the logo centred. Nav items start at opacity 0. The rest of the content is pre-shifted "ever so slightly" down so it slides up with the loader. Hold for 1000ms, then the loader exits upward over 800ms on a custom bezier with handles dragged out (an exponential, expo-like curve). After a 100ms delay the nav fades in with Smart Animate, ease-in-out, 200ms.
- Expanding nav, built backwards: the full bar, then a circle (width matched to height, 53×53px), then a 1×1px dot, then a transparent dot. Timing: wait 800ms, then cut instantly; the dot grows to a circle (Smart Animate, ease-in-out, 300ms); the circle grows to the full bar (custom exponential bezier, 400ms); then menu, logo and "Join us" fade in one after another (each ease-in-out 200ms, about 1ms delays).
- Text wipe: a 1px-wide bar slightly taller than the text, in the text colour. Wait 800ms; the bar grows across the text (custom exponential bezier, 700ms); cut instantly to the text visible under the bar; the bar slides off to the far side (700ms, the same curve); then the bar is hidden.
- General: chain about 1ms delays and instant cuts between frames to sequence steps. Use the exponential custom curve for big movements and short ease-in-out for opacity.

