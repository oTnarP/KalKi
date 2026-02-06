# **KalKi — App Plan & Product Specification**

## 1. Problem KalKi Solves

KalKi exists to remove **daily decision fatigue** for people living alone in Bangladesh.

A single person in a busy city like Dhaka faces two recurring problems:

1. Every night: _“Kal ki ranna?”_ (What will I cook tomorrow?)
2. Every market visit: _“Ki ki kinbo?”_ (What should I buy so I don’t forget essentials?)

KalKi solves both problems together:

- It **decides tomorrow’s food**
- It **tells what to buy**, including daily-life essentials

No recipes, no nutrition theory, no foreign food culture.

---

## 2. Core Philosophy

KalKi is built on these principles:

- **Tomorrow-first** (not long-term planning)
- **Bangladeshi home food only**
- **Single-living mindset**
- **Decision removal over choice expansion**
- **Offline-first**
- **Minimal mental interaction**

KalKi does not try to teach cooking.
It assumes the user already knows how to cook.

---

## 3. What KalKi Is (Conceptually)

KalKi is a **daily life assistant**, not a food app.

It behaves like:

- A mother deciding tomorrow’s খাবার
- An older sibling reminding what to buy from bazaar

It provides **suggestions**, not control.

---

## 4. Primary User

- Lives alone in an apartment or mess
- Cooks simple Bangladeshi food
- Shops frequently in local bazaar or supershop
- Wants to save **time and mental energy**
- Does not want complex apps

KalKi is especially designed for:

- Working professionals
- Students
- People away from family

---

## 5. Core Functional Blocks

KalKi has **three logical blocks**, tightly connected.

---

### Block A — Tomorrow’s Meal Planning

KalKi always focuses on **tomorrow**, not today.

For each day, KalKi suggests:

- Lunch
- Dinner
- Optional snack / light food

Rules:

- Only Bangladeshi dishes
- Simple home-style food
- No foreign cuisines
- No recipes or cooking steps
- Avoid repeating yesterday’s main dishes
- Respect dietary preferences (fish/chicken/beef/veg)

The user can:

- Accept the suggestion
- Regenerate suggestions
- Lock the plan for tomorrow

Once locked, KalKi treats tomorrow’s plan as final.

---

### Block B — Automatic Bazaar List (Cooking-Based)

From the selected meal plan, KalKi automatically generates a **bazaar list for cooking**.

This list:

- Is derived directly from dishes
- Includes ingredients needed
- Merges duplicates
- Shows simple quantity hints (optional)

Purpose:

- User does not need to think _“what ingredients do I need?”_
- User can quickly check the list while shopping

This list updates automatically if meals change.

---

### Block C — A–Z Daily Essentials (Single Living)

KalKi also maintains a **permanent essentials list** for daily life.

This list represents what a single person typically needs, such as:

- Breakfast items
- Snacks
- Tea/coffee items
- Cooking basics
- Home & personal items
- Emergency or lazy-day food

Characteristics:

- Pre-filled with Bangladeshi context
- Fully customizable
- Users can star frequently bought items
- Users can add or disable items

This list is **not tied to meal planning**, but complements it.

---

## 6. Market Mode (Context-Aware Behavior)

KalKi has a special mode for when the user is physically in the market.

When activated:

- The app behaves like a checklist
- Shows:
  - Cooking ingredients for tomorrow
  - Starred essentials
  - Other enabled essentials

- Allows quick tick/untick

Purpose:

- Reduce confusion
- Prevent forgetting items
- Enable fast decision-free shopping

Market Mode is temporary and resettable.

---

## 7. Notifications & Reminders

KalKi uses **local notifications only**.

Types of reminders:

1. **Night reminder**
   - Prompts user to decide tomorrow’s meals

2. **Cooking reminders**
   - Reminds at lunch/dinner time based on user settings

Notification behavior:

- Friendly
- Short
- Familiar tone
- Not aggressive

Notifications adapt based on plan status (locked/unlocked).

---

## 8. Customization & User Control

KalKi allows customization without complexity.

Users can:

- Enable or disable food categories
- Block certain foods on certain days
- Add their own dishes
- Add their own essential items
- Star important items
- Adjust reminder times

KalKi never forces anything.

---

## 9. Data & Privacy Philosophy

- No login required
- No internet required
- All data stored locally
- No tracking by default
- No data leaves the device

KalKi respects personal daily habits.

---

## 10. What KalKi Intentionally Does NOT Do

KalKi is **not**:

- A recipe app
- A nutrition tracker
- A calorie counter
- A grocery delivery app
- A social app
- A meal subscription service

These are deliberately excluded to keep mental load low.

---

## 11. Long-Term Vision (Optional, Not MVP)

In future versions, KalKi could:

- Learn frequently cooked meals (locally)
- Suggest weekly rotations
- Support seasonal food awareness
- Add Bengali language support fully

But v1 remains simple and focused.

---

## 12. One-Line Summary (for AI UI Prompt)

> **KalKi is a minimal, offline Bangladeshi daily-life app that decides tomorrow’s meals and automatically generates a market checklist, designed specifically for people living alone who want to stop wasting time thinking about what to cook and what to buy.**
