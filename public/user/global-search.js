/**
 * Smart Lishe - Global Search Engine
 * Real-time instant search across Recipes, Health Conditions, and App Tools
 */

(function () {
  'use strict';

  // 1. GLOBAL SEARCH INDEX
  const SEARCH_INDEX = {
    recipes: [
      {
        name: 'Ugali & Sukuma Wiki',
        category: 'Main Dish',
        time: '15 min',
        calories: 450,
        img: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop',
        tags: 'staple, cornmeal, collard greens, vegetarian',
        url: 'recipes.html?search=Ugali%20%26%20Sukuma%20Wiki'
      },
      {
        name: 'Nyama Choma & Kachumbari',
        category: 'Protein Special',
        time: '35 min',
        calories: 520,
        img: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=400&auto=format&fit=crop',
        tags: 'grilled beef, goat meat, tomato salad, high protein',
        url: 'recipes.html?search=Nyama%20Choma'
      },
      {
        name: 'Mukimo & Beef Stew',
        category: 'Traditional',
        time: '40 min',
        calories: 580,
        img: 'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=400&auto=format&fit=crop',
        tags: 'mashed potatoes, corn, pumpkin leaves, rich stew',
        url: 'recipes.html?search=Mukimo'
      },
      {
        name: 'Githeri Special',
        category: 'High Fibre',
        time: '25 min',
        calories: 420,
        img: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=400&auto=format&fit=crop',
        tags: 'maize, kidney beans, avocado, vegan, fibre',
        url: 'recipes.html?search=Githeri'
      },
      {
        name: 'Tilapia Fry & Ugali',
        category: 'Seafood',
        time: '30 min',
        calories: 490,
        img: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?q=80&w=400&auto=format&fit=crop',
        tags: 'lake Victoria fish, omega 3, heart healthy',
        url: 'recipes.html?search=Tilapia'
      },
      {
        name: 'Chapati & Dengu',
        category: 'Vegetarian',
        time: '35 min',
        calories: 510,
        img: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=400&auto=format&fit=crop',
        tags: 'flatbread, green grams curry, plant protein',
        url: 'recipes.html?search=Dengu'
      },
      {
        name: 'Kienyeji Chicken Stew',
        category: 'Traditional',
        time: '50 min',
        calories: 530,
        img: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=400&auto=format&fit=crop',
        tags: 'free range chicken, organic, iron rich',
        url: 'recipes.html?search=Kienyeji'
      },
      {
        name: 'Pilau Ya Nyama',
        category: 'Swahili Delight',
        time: '45 min',
        calories: 560,
        img: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=400&auto=format&fit=crop',
        tags: 'spiced rice, beef tenderloin, celebration dish',
        url: 'recipes.html?search=Pilau'
      },
      {
        name: 'Matoke & Beef Stew',
        category: 'Traditional',
        time: '30 min',
        calories: 460,
        img: 'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=400&auto=format&fit=crop',
        tags: 'green bananas, potassium rich, beef stew',
        url: 'recipes.html?search=Matoke'
      },
      {
        name: 'Omena Fry & Greens',
        category: 'High Calcium',
        time: '20 min',
        calories: 380,
        img: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?q=80&w=400&auto=format&fit=crop',
        tags: 'sardines, calcium, iron, affordable meal',
        url: 'recipes.html?search=Omena'
      },
      {
        name: 'Boiled Nduma (Arrowroots)',
        category: 'Breakfast / Snack',
        time: '20 min',
        calories: 290,
        img: 'https://images.unsplash.com/photo-1509722747041-616f39b57569?q=80&w=400&auto=format&fit=crop',
        tags: 'low GI carb, tea snack, ulcer friendly',
        url: 'recipes.html?search=Nduma'
      }
    ],

    conditions: [
      {
        id: 'diabetes',
        name: 'Diabetes & Prediabetes',
        desc: 'Low Glycemic Index choices, brown ugali, dengu & portion control.',
        icon: 'fa-droplet',
        url: 'health-conditions.html?condition=diabetes'
      },
      {
        id: 'hypertension',
        name: 'Hypertension (High BP)',
        desc: 'Low sodium DASH diet, potassium-rich managu & bananas.',
        icon: 'fa-heart-pulse',
        url: 'health-conditions.html?condition=hypertension'
      },
      {
        id: 'ulcers',
        name: 'Ulcers & Acid Reflux',
        desc: 'Mild non-acidic foods, boiled arrowroots, oat porridge & pumpkin.',
        icon: 'fa-notes-medical',
        url: 'health-conditions.html?condition=ulcers'
      },
      {
        id: 'obesity',
        name: 'Weight Loss & Obesity',
        desc: 'High protein, high fibre, calorie-controlled traditional meals.',
        icon: 'fa-weight-scale',
        url: 'health-conditions.html?condition=obesity'
      },
      {
        id: 'anemia',
        name: 'Anemia & Low Iron',
        desc: 'Iron-rich managu, terere, omena & vitamin C boosters.',
        icon: 'fa-tint',
        url: 'health-conditions.html?condition=anemia'
      },
      {
        id: 'pregnancy',
        name: 'Pregnancy & Lactation',
        desc: 'Folate, calcium, kienyeji chicken, sweet potato & iron.',
        icon: 'fa-baby',
        url: 'health-conditions.html?condition=pregnancy'
      }
    ],

    tools: [
      {
        name: 'AI Meal Assistant',
        desc: 'Chat with Smart Lishe AI for instant Kenyan meal advice',
        icon: 'fa-robot',
        url: 'ai-assistant.html'
      },
      {
        name: 'AI Meal Generator',
        desc: 'Generate instant custom daily or weekly meal plans',
        icon: 'fa-wand-magic-sparkles',
        url: 'meal-generator.html'
      },
      {
        name: 'NutriScan AI Camera',
        desc: 'Scan food photos for instant calorie and nutrient breakdown',
        icon: 'fa-camera-retro',
        url: 'nutriscan.html'
      },
      {
        name: 'Weekly Meal Planner',
        desc: 'Organize breakfast, lunch, and dinner for the week',
        icon: 'fa-calendar-days',
        url: 'meal-planner.html'
      },
      {
        name: 'Smart Shopping List',
        desc: 'Auto-compiled grocery list with estimated costs in KSh',
        icon: 'fa-basket-shopping',
        url: 'shopping-list.html'
      },
      {
        name: 'Water & Hydration Tracker',
        desc: 'Log daily water intake and stay hydated',
        icon: 'fa-glass-water',
        url: 'water-tracker.html'
      },
      {
        name: 'Goal & Weight Tracker',
        desc: 'Track weight progress, BMI, and target milestones',
        icon: 'fa-bullseye',
        url: 'goal-tracker.html'
      },
      {
        name: 'Health Conditions',
        desc: 'Manage dietary plans for Diabetes, High BP, Ulcers, Anemia',
        icon: 'fa-heart-pulse',
        url: 'health-conditions.html'
      },
      {
        name: 'Nutrition Analytics',
        desc: 'Visual graphs of daily calories, macronutrients & trends',
        icon: 'fa-chart-pie',
        url: 'analytics.html'
      }
    ]
  };

  let activeHighlightIndex = -1;

  function initGlobalSearchEngine() {
    const searchBox = document.querySelector('.topbar .search-box');
    const input = document.getElementById('globalSearch');
    if (!input || !searchBox) return;

    // 1. Ensure Clear Button exists
    let clearBtn = searchBox.querySelector('.search-clear-btn');
    if (!clearBtn) {
      clearBtn = document.createElement('i');
      clearBtn.className = 'fa-solid fa-xmark search-clear-btn';
      clearBtn.setAttribute('title', 'Clear search');
      searchBox.appendChild(clearBtn);
    }

    // 2. Ensure Dropdown container exists
    let dropdown = searchBox.querySelector('.global-search-dropdown');
    if (!dropdown) {
      dropdown = document.createElement('div');
      dropdown.className = 'global-search-dropdown';
      dropdown.id = 'globalSearchDropdown';
      searchBox.appendChild(dropdown);
    }

    // 3. Clear Button Event
    clearBtn.addEventListener('click', () => {
      input.value = '';
      clearBtn.style.display = 'none';
      hideDropdown(dropdown);
      input.focus();

      // If on recipes page, reset recipe filter
      const recipeSearch = document.getElementById('recipeSearchInput');
      if (recipeSearch) {
        recipeSearch.value = '';
        if (typeof window.filterRecipes === 'function') {
          window.filterRecipes();
        }
      }
    });

    // 4. Input Listener
    input.addEventListener('input', (e) => {
      const query = e.target.value.trim();
      if (query.length > 0) {
        clearBtn.style.display = 'block';
        renderSearchResults(query, dropdown);
      } else {
        clearBtn.style.display = 'none';
        hideDropdown(dropdown);
      }

      // Live sync with recipe filter if on recipes.html
      const recipeSearch = document.getElementById('recipeSearchInput');
      if (recipeSearch && recipeSearch !== input) {
        recipeSearch.value = query;
        if (typeof window.filterRecipes === 'function') {
          window.filterRecipes();
        }
      }
    });

    // 5. Focus Listener
    input.addEventListener('focus', () => {
      const query = input.value.trim();
      if (query.length > 0) {
        clearBtn.style.display = 'block';
        renderSearchResults(query, dropdown);
      } else {
        // Show quick suggestions / popular searches
        renderSearchResults('', dropdown);
      }
    });

    // 6. Keyboard Shortcuts Navigation
    input.addEventListener('keydown', (e) => {
      const items = dropdown.querySelectorAll('.gs-item');
      if (!dropdown.classList.contains('show') || items.length === 0) {
        if (e.key === 'Enter') {
          e.preventDefault();
          const query = input.value.trim();
          if (query) {
            handleSearchSubmit(query);
          }
        }
        return;
      }

      if (e.key === 'ArrowDown') {
        e.preventDefault();
        activeHighlightIndex = (activeHighlightIndex + 1) % items.length;
        updateActiveItem(items);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        activeHighlightIndex = (activeHighlightIndex - 1 + items.length) % items.length;
        updateActiveItem(items);
      } else if (e.key === 'Enter') {
        e.preventDefault();
        if (activeHighlightIndex >= 0 && activeHighlightIndex < items.length) {
          items[activeHighlightIndex].click();
        } else {
          const query = input.value.trim();
          if (query) {
            handleSearchSubmit(query);
          }
        }
      } else if (e.key === 'Escape') {
        hideDropdown(dropdown);
      }
    });

    // 7. Click Outside
    document.addEventListener('click', (e) => {
      if (!searchBox.contains(e.target)) {
        hideDropdown(dropdown);
      }
    });

    // 8. Handle URL Query Parameters
    handleUrlQueryParams(input);
  }

  function renderSearchResults(query, dropdown) {
    activeHighlightIndex = -1;
    const q = query.toLowerCase().trim();

    if (!q) {
      // Popular / Quick Suggestions
      let html = `
        <div class="gs-header">
          <span>Popular Searches</span>
          <span style="font-size:0.7rem;opacity:0.7;">Quick Jump</span>
        </div>
        <div class="gs-category-title"><i class="fa-solid fa-wand-magic-sparkles"></i> Popular Items</div>
      `;

      // Pick 3 popular recipes + 2 features
      const popularRecipes = SEARCH_INDEX.recipes.slice(0, 3);
      const popularTools = SEARCH_INDEX.tools.slice(0, 2);

      popularRecipes.forEach(r => {
        html += renderRecipeItem(r);
      });
      popularTools.forEach(t => {
        html += renderToolItem(t);
      });

      dropdown.innerHTML = html;
      attachItemListeners(dropdown);
      showDropdown(dropdown);
      return;
    }

    // Filter Items
    const matchedRecipes = SEARCH_INDEX.recipes.filter(r =>
      r.name.toLowerCase().includes(q) ||
      r.category.toLowerCase().includes(q) ||
      r.tags.toLowerCase().includes(q)
    );

    const matchedConditions = SEARCH_INDEX.conditions.filter(c =>
      c.name.toLowerCase().includes(q) ||
      c.desc.toLowerCase().includes(q) ||
      c.id.toLowerCase().includes(q)
    );

    const matchedTools = SEARCH_INDEX.tools.filter(t =>
      t.name.toLowerCase().includes(q) ||
      t.desc.toLowerCase().includes(q)
    );

    const totalCount = matchedRecipes.length + matchedConditions.length + matchedTools.length;

    if (totalCount === 0) {
      dropdown.innerHTML = `
        <div class="gs-no-results">
          <i class="fa-solid fa-magnifying-glass" style="font-size:1.8rem;color:var(--text-muted);margin-bottom:8px;display:block;"></i>
          <strong>No matches found for "${escapeHtml(query)}"</strong>
          <p style="font-size:0.78rem;margin-top:4px;color:var(--text-muted);">Press Enter to search all recipes on the Recipes page.</p>
        </div>
      `;
      attachItemListeners(dropdown);
      showDropdown(dropdown);
      return;
    }

    let html = `
      <div class="gs-header">
        <span>Search Results</span>
        <span class="gs-badge">${totalCount} match${totalCount > 1 ? 'es' : ''}</span>
      </div>
    `;

    if (matchedRecipes.length > 0) {
      html += `<div class="gs-category-title"><i class="fa-solid fa-utensils"></i> Recipes & Meals</div>`;
      matchedRecipes.forEach(r => { html += renderRecipeItem(r); });
    }

    if (matchedConditions.length > 0) {
      html += `<div class="gs-category-title"><i class="fa-solid fa-heart-pulse"></i> Health Conditions</div>`;
      matchedConditions.forEach(c => { html += renderConditionItem(c); });
    }

    if (matchedTools.length > 0) {
      html += `<div class="gs-category-title"><i class="fa-solid fa-compass"></i> App Tools & Features</div>`;
      matchedTools.forEach(t => { html += renderToolItem(t); });
    }

    dropdown.innerHTML = html;
    attachItemListeners(dropdown);
    showDropdown(dropdown);
  }

  function renderRecipeItem(r) {
    return `
      <div class="gs-item" data-type="recipe" data-name="${escapeHtml(r.name)}" data-url="${r.url}">
        <img class="gs-item-icon" src="${r.img}" alt="${escapeHtml(r.name)}">
        <div class="gs-item-info">
          <div class="gs-item-title">${escapeHtml(r.name)}</div>
          <div class="gs-item-sub"><i class="fa-regular fa-clock"></i> ${r.time} • ${r.calories} kcal • ${r.category}</div>
        </div>
        <span class="gs-badge">Recipe</span>
      </div>
    `;
  }

  function renderConditionItem(c) {
    return `
      <div class="gs-item" data-type="condition" data-id="${c.id}" data-url="${c.url}">
        <div class="gs-item-icon" style="background:rgba(193,68,14,0.1);color:#C1440E;">
          <i class="fa-solid ${c.icon}"></i>
        </div>
        <div class="gs-item-info">
          <div class="gs-item-title">${escapeHtml(c.name)}</div>
          <div class="gs-item-sub">${escapeHtml(c.desc)}</div>
        </div>
        <span class="gs-badge" style="background:rgba(193,68,14,0.12);color:#C1440E;">Health</span>
      </div>
    `;
  }

  function renderToolItem(t) {
    return `
      <div class="gs-item" data-type="tool" data-url="${t.url}">
        <div class="gs-item-icon">
          <i class="fa-solid ${t.icon}"></i>
        </div>
        <div class="gs-item-info">
          <div class="gs-item-title">${escapeHtml(t.name)}</div>
          <div class="gs-item-sub">${escapeHtml(t.desc)}</div>
        </div>
        <span class="gs-badge" style="background:rgba(46,125,50,0.12);color:var(--sukuma);">Tool</span>
      </div>
    `;
  }

  function attachItemListeners(dropdown) {
    dropdown.querySelectorAll('.gs-item').forEach((item) => {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        const type = item.dataset.type;
        const url = item.dataset.url;
        const name = item.dataset.name;

        if (window.location.pathname.endsWith('recipes.html') && type === 'recipe') {
          // On recipes page: open modal if available or filter
          hideDropdown(dropdown);
          if (typeof window.openRecipeModal === 'function' && name) {
            window.openRecipeModal(name);
          } else {
            const recipeSearch = document.getElementById('recipeSearchInput');
            if (recipeSearch) {
              recipeSearch.value = name;
              if (typeof window.filterRecipes === 'function') window.filterRecipes();
            }
          }
        } else {
          window.location.href = url;
        }
      });
    });
  }

  function updateActiveItem(items) {
    items.forEach((item, idx) => {
      if (idx === activeHighlightIndex) {
        item.classList.add('active');
        item.scrollIntoView({ block: 'nearest' });
      } else {
        item.classList.remove('active');
      }
    });
  }

  function handleSearchSubmit(query) {
    if (window.location.pathname.endsWith('recipes.html')) {
      const recipeSearch = document.getElementById('recipeSearchInput');
      if (recipeSearch) {
        recipeSearch.value = query;
        if (typeof window.filterRecipes === 'function') window.filterRecipes();
        const grid = document.getElementById('recipeGrid');
        if (grid) grid.scrollIntoView({ behavior: 'smooth' });
      }
    } else {
      window.location.href = `recipes.html?search=${encodeURIComponent(query)}`;
    }
  }

  function handleUrlQueryParams(globalInput) {
    try {
      const urlParams = new URLSearchParams(window.location.search);
      const searchParam = urlParams.get('search') || urlParams.get('q');
      const conditionParam = urlParams.get('condition');

      if (searchParam && globalInput) {
        globalInput.value = searchParam;
        const clearBtn = document.querySelector('.search-clear-btn');
        if (clearBtn) clearBtn.style.display = 'block';

        if (window.location.pathname.endsWith('recipes.html')) {
          const recipeSearch = document.getElementById('recipeSearchInput');
          if (recipeSearch) {
            recipeSearch.value = searchParam;
            setTimeout(() => {
              if (typeof window.filterRecipes === 'function') window.filterRecipes();
            }, 100);
          }
        }
      }

      if (conditionParam && window.location.pathname.endsWith('health-conditions.html')) {
        setTimeout(() => {
          const card = document.getElementById(`condition-${conditionParam}`) || document.querySelector(`[data-condition="${conditionParam}"]`);
          if (card) {
            card.scrollIntoView({ behavior: 'smooth' });
            card.click();
          }
        }, 200);
      }
    } catch (err) {
      console.warn('URL params check failed:', err);
    }
  }

  function showDropdown(dropdown) {
    dropdown.classList.add('show');
  }

  function hideDropdown(dropdown) {
    dropdown.classList.remove('show');
    activeHighlightIndex = -1;
  }

  function escapeHtml(str) {
    return (str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  // BOOT ENGINE
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initGlobalSearchEngine);
  } else {
    initGlobalSearchEngine();
  }
})();
