# Picture This — Founder Vision

This is the source document the app is built from. Preserved verbatim so
the product direction stays anchored as the codebase grows.

## Founder Vision

Picture This is not another social media app.
It is an AI lifestyle operating system.
Its purpose is to help people discover who they truly are by experimenting
with different lifestyles, aesthetics, hobbies, music, movies, books,
clothing, food, travel, routines, and experiences.

The app should feel like having an incredibly intelligent best friend that
understands you better every single day.

The goal isn't engagement.
The goal is self-discovery.

## Core Philosophy

Every recommendation is an experiment.

Instead of asking "What should I watch?", Picture This asks "Who do you
want to become today?"

Instead of doom scrolling, users intentionally choose experiences. The app
then learns from every experience. Eventually it understands the user
better than they understand themselves.

## The Main Loop

Choose a vibe → Receive recommendations → Experience them → Reflect → AI
learns → Recommendations improve → User discovers themselves. Repeat
forever.

## The Four Pillars

### 1. Discover

Find new experiences — movies, TV shows, books, music, podcasts,
restaurants, recipes, coffee shops, cities, travel, activities, sports,
hobbies, fashion, cologne, perfume, home decor, art, photography, video
games, events — anything that contributes to a lifestyle.

### 2. Experience

Users actually do the recommendation. The app tracks real experiences:
"I watched the movie," "I tried the coffee shop," "I went hiking."

### 3. Reflect

Every recommendation receives feedback: how much did you enjoy it, would
you do it again, how did it make you feel, would you recommend it, did it
match your vibe, would your future self enjoy this, an optional journal
entry, mood before, mood after.

### 4. Learn

AI builds a living personality model: patterns, preferences, dislikes,
energy levels, seasonality, weather preferences, social preferences,
personality, goals, dreams, values. Eventually recommendations become
almost magical.

## AI Companion

The AI is the center of the app. It should feel alive — noticing patterns
users never would ("You've become much more adventurous," "You
consistently enjoy indie coffee shops over chains").

## Personality Profile

Fun, not demographic: favorite movies/books/music/artist/color/food, dogs
or cats, coffee or tea, beach or mountains, morning or night,
introvert/extrovert, Hogwarts House, Divergent faction, Jedi or Sith,
Marvel or DC, favorite season/city, dream vacation/career, love language,
Enneagram, MBTI, Big Five, core values, life goals, bucket list, dream
house/car, favorite quote/character/outfit style/sport/hobby.

## Vibes

Everything revolves around vibes: Old Money, Dark Academia, Coastal
Grandmother, Quiet Luxury, Cottagecore, Light Academia, Cyberpunk, Vintage
Americana, Parisian, Italian Summer, Y2K, 90s, Minimalist, Adventure,
Cozy, Romantic, Luxury, Bookstore, Rainy Day, Mountain Cabin, Beach House,
Preppy, Streetwear, Western, Country Club, Film Student, Artist,
Entrepreneur, CEO, Traveler, Surfer, Skater, Musician, Photographer,
Writer, Nature Lover, Coffee Shop, Late Night Drive, European Summer,
Small Town, Big City — an endless list.

### Vibe Pages

Every vibe has its own page: description, history, colors, music, movies,
books, fashion, shoes, activities, cities, countries, restaurants, coffee,
architecture, weather, photography, vehicles, quotes, people, celebrities,
interior design, cologne, food, drinks — everything related to that vibe.

### Apply This Vibe

One button builds an entire day: breakfast, coffee, outfit, playlist,
book, movie, restaurant, activity, walk location, journal prompt,
photography prompt, dessert, night routine. An entire lifestyle.

## Daily AI Suggestions

"Good morning. Today feels perfect for... a rainy coffee shop. A black
turtleneck. Jazz. Reading Kafka. Walking downtown. Trying a new bakery.
Watching Before Sunrise tonight." The AI creates complete experiences.

## Experiment Journal

Every recommendation becomes an experiment: name, date, what happened,
expectation, reality, rating, mood before, mood after, lessons learned,
would repeat.

## Timeline

The app remembers everything — first solo trip, first concert, favorite
coffee shop, most life-changing movie, books that changed your life, best
vacation, hardest year, favorite birthday. Life becomes searchable.

## AI Memory

The AI remembers everything and uses it naturally — "You love rainy
weather," "You hate loud restaurants," "You always order chai."

## Community

Optional. Share experiments, journals, playlists, vibe boards; recommend,
vote, comment, follow creators. Not endless scrolling — quality over
quantity.

## Voting System

Every recommendation can receive: Love, Like, Neutral, Dislike, Never
Again. This continuously trains recommendations.

## Collections

User-created lists: Perfect Fall Movies, Dream Coffee Shops, Books That
Changed Me, Best Date Ideas, Future Trips, Restaurants, Favorite Outfits,
Favorite Quotes.

## AI Insights

"Your happiest days usually include: coffee, walking, reading, sunsets,
friends, soccer, music." The app discovers hidden patterns.

## Maps

A map of experiences: visited coffee shops, restaurants, museums,
national parks, travel history, bucket list.

## Long-Term Vision

Picture This becomes: Spotify for lifestyles, Pinterest with intelligence,
Letterboxd for life, Goodreads for experiences, Notion for memories,
ChatGPT for self-discovery — all combined into one product.

## Design Philosophy

Minimal. Beautiful. Warm. Apple-level polish. Nothing cluttered. Large
photography. Elegant typography. Subtle animations. Glassmorphism used
sparingly. Dark and light mode. **The app should feel luxurious — this
cannot be overstated.** Think Pinterest, VSCO: remarkably beautiful.

## Technical Requirements

- Flutter for iOS and Android from a single codebase.
- Firebase Authentication (Google, Apple, Email).
- Firestore for user profiles, experiments, journals, and collections.
- Firebase Storage for uploaded images.
- An AI layer that builds a continuously evolving user preference graph.
- Modular architecture with clean separation of UI, business logic, and
  data.
- Offline support with sync when connectivity returns.
- A recommendation engine designed to improve over time using user
  feedback.
- A scalable backend that can later integrate with external APIs
  (Spotify, Letterboxd, Goodreads, weather, maps, etc.).

---

See `docs/ARCHITECTURE.md` for how this first build pass maps onto the
vision, and what's deliberately not built yet.
