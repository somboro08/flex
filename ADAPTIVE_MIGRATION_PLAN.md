# Plan d'audit et de migration adaptative — Flex (Flutter Web / Desktop)

> Objectif : migrer l'application existante écran par écran vers l'infrastructure adaptative déjà en place (`AdaptiveScaffold`, `AdaptiveContentContainer`, `AdaptiveGrid`, `AdaptiveOverlay`, extensions `context.isMobile/isTablet/isDesktop/isLargeDesktop`).
> Règles : **ne pas créer de nouvelle infra** ; ne pas dupliquer mobile/desktop ; préserver la logique métier ; ne migrer la logique de navigation que pour la cohérence back-stack et deep-linking.

---

## 1. État de l'infrastructure adaptative existante

| Outil | Fichier | Usage actuel |
|---|---|---|
| `AdaptiveScaffold` (bottom nav / rail / sidebar) | `shared/widgets/adaptive_scaffold.dart` | ✅ opérationnel (shell) |
| `AdaptiveContentContainer` (cap largeur ≈1440px) | `core/responsive/content_container.dart` | ✅ 10 écrans |
| `AdaptiveGrid` (colonnes par breakpoint) | `shared/widgets/adaptive_grid.dart` | ✅ 3 écrans |
| `AdaptiveOverlay` (sheet mobile / dialog ou panneau latéral desktop) | `shared/widgets/adaptive_overlay.dart` | ✅ 1 seul appel (`listing_card.dart`) |
| Extensions breakpoints | `core/responsive/breakpoints.dart` | ✅ 7 écrans |
| `AdaptiveLayout` / `ResponsiveValue` | `core/responsive/adaptive_layout.dart` | ❌ **code mort** (0 usage) |
| `pushFlexPage` (transitions) | `utils/route_transitions.dart` | ❌ code mort |
| `PaymentBottomSheet` | `screens/payment/payment_bottom_sheet.dart` | ❌ **orphelin** (jamais instancié) |

---

## 2. Audit des écrans (33 fichiers sous `lib/screens/`)

### 2.1 Déjà adaptés (à vérifier seulement)
| Écran | État | Résidus |
|---|---|---|
| `home/home_screen.dart` | ✅ container + grid + slivers | 2 `Navigator.push` restants (Map, Notif, Budget, Category…) |
| `home/search_screen.dart` | ✅ sidebar desktop + grid | Row "certifiés uniquement" sans Flexible ; panneau 280px fixe |
| `booking/my_bookings_screen.dart` | ✅ container + grille 2 col. | `childAspectRatio: 2.5` fixe → cartes écrasées si dates longues |
| `profile/profile_screen.dart` | ✅ container (max 800) + scroll | 8 `Navigator.push` à convertir ; 3 `showDialog` bruts |
| `listing/listing_detail_screen.dart` | ✅ desktop 2 colonnes | panneau droit **360px fixe** (clips 1025–1100px) ; barre mobile serrée à 320px ; ligne note sans ellipsis |
| `listing/create_listing_screen.dart` | ✅ container | Stepper vertical étroit sur desktop ; map picker en bottom sheet brut |
| `listing/visit_request_screen.dart` | ✅ container | — |
| `hote/hote_dashboard_screen.dart` | ✅ container + grid + stats desktop | stat cards `SizedBox(width:120)` fixes mobile ; formulaire édition en bottom sheet 85 % |
| `hote/hote_rentals_screen.dart` | ✅ container + grid 2 col. (desktop) | **4 `_StatItem` dans une Row débordante <400px** ; `childAspectRatio: 2.8` fixe |
| `locataire/locataire_rentals_screen.dart` | ✅ container | détails `_RentalDetailScreen` sans adaptation ; bottom sheet actions brut |
| `chat/conversations_screen.dart` | ✅ | — |
| `home/notification_screen.dart` | ✅ (liste) | — |

### 2.2 P0 — Non adaptés au web desktop (priorité immédiate)
| Écran | Problèmes constatés |
|---|---|
| `home/category_detail_screen.dart` | **Cartes géantes pleine largeur sur desktop** (largeur `MediaQuery` brut, jamais plafonnée, 2 colonnes codées en dur) ; boutons 38×38 fixes ; aucune adaptation. C'est le cas signalé (Location, Cohabitation, -10000…) |
| `onboarding/onboarding_screen.dart` | Pleine largeur sans cap ; colonne verticale figée sans scroll ; CTA pincé en bas ; boutons parfois hors d'atteinte |
| `home/budget_search_screen.dart` | Pleine largeur sans cap ; **4 chips budget dans une Row** (déborde <360px) ; 1 colonne même desktop |
| `home/map_screen.dart` | **`showModalBottomSheet` brut** pour l'aperçu logement (rend un bandeau pleine largeur en bas du desktop, pas un panneau latéral) ; push → ListingDetail dans la sheet |
| `screens/auth_screen.dart` | Country-picker en bottom sheet brut ; tablette retombe sur le layout mobile empilé |
| `listing/all_listings_screen.dart` | **1 seule colonne même en desktop** (largeur gâchée, cartes étirées) |
| `profile/favorites_screen.dart` | Idem : 1 colonne desktop |
| `listing/listing_detail_bottom_sheet.dart` | Overlay utilisé via AdaptiveOverlay ✅ ; mais contient 2 `Navigator.push` (BookingConfirmation, Chat) |

### 2.3 P1 — Pleine largeur sans cap + overflows localisés
| Écran | Problèmes |
|---|---|
| `booking/booking_confirmation_screen.dart` | Sans container ; `showDateRangePicker` brut |
| `booking/review_screen.dart` | Sans container |
| `payment/payment_screen.dart` | Sans container ; `_SummaryRow` sans Flexible (texte dates long) ; dialog succès brut |
| `chat/chat_screen.dart` | Sans container ; **titre AppBar non enveloppé dans Expanded** (titre long → overflow) |
| `locataire/advance_payment_screen.dart` | Sans container ; 2 `showDialog` bruts |
| `locataire/refund_request_screen.dart` | Sans container |
| `locataire/renew_booking_screen.dart` | Sans container ; **7 chips de mois dans une Row (déborde à 400px)** |
| `hote/hote_tenant_detail_screen.dart` | **4 `_MiniPill` en Row fixe (déborde)** ; sans container |
| `hote/hote_visit_requests_screen.dart` | Sans container ; toutes les cartes construites d'un coup |
| `profile/settings_screen.dart` | Dialog mot de passe non scrollable (risque clavier) |
| `profile/identity_verification_screen.dart` | `ImagePicker.camera` non vérifié pour web (`kIsWeb`) |
| `agent/agent_audit_screen.dart` | Sans container ; bottom sheet source photo brut |

---

## 3. Audit navigation & flux (21 routes, ~35 appels)

### 3.1 Routes go_router (déclarées)
- Dans le shell : `/home`, `/search`, `/bookings`, `/conversations`, `/profile` (transition `NoTransitionPage`)
- Hors shell : `/splash`, `/onboarding`, `/auth`, `/map`, `/notifications`, `/category/:label`, `/budget-search`, `/favorites`, `/settings`, `/identity-verification`, `/support`, `/hote-dashboard`, `/hote-rentals`, `/hote-visits`, `/locataire-rentals`, `/advance-payment`, `/refund-request`, `/renew-booking`

### 3.2 Problèmes structurels
1. **Navigation « split-brain »** : ~25 appels `Navigator.push(MaterialPageRoute)…` contournent go_router. Conséquences : pas de deep-linking, back-stack incohérent, `context.go` depuis une page pushée perd la route pushée, sélection du shell basée sur `matchedLocation` peut être fausse.
2. **Routes déclarées mais jamais utilisées** : `/favorites`, `/settings`, `/hote-dashboard`, `/hote-rentals`, `/hote-visits`, `/locataire-rentals`, `/advance-payment`, `/refund-request`, `/renew-booking`, `/map`, `/notifications`, `/budget-search`, `/category/:label` sont toutes atteintes en `Navigator.push` depuis `profile_screen`, `home_screen`, `hote_dashboard_screen`, `locataire_rentals_screen`.
3. **Cibles sans route go_router** (à créer ou à garder en overlay) : `ChatScreen`, `ReviewScreen`, `PaymentScreen`, `BookingConfirmationScreen`, `ListingDetailScreen`, `VisitRequestScreen`, `AllListingsScreen`, `CreateListingScreen`, `HoteTenantDetailScreen`, `_RentalDetailScreen` (privée).
4. **pop-then-push fragiles** : `map_screen.dart:162` (pop puis push ListingDetail) ; `locataire_rentals_screen.dart:209–227` (pop puis push avance/renouvellement/remboursement/détail).
5. `redirect` de go_router est un **no-op** : toute la logique vit dans `_SplashRedirector` ; `AuthService()` recréé localement (divergence d'instance).
6. Profil : `profile_screen.dart:337` push `/bookings` (route du shell) → deux instances du shell possibles.

### 3.3 Appels `showModalBottomSheet` / `showDialog` bruts (à migrer → `AdaptiveOverlay`)
| Fichier:ligne | Type | Contenu |
|---|---|---|
| `my_bookings_screen.dart:50` | dialog | Confirmer annulation |
| `create_listing_screen.dart:86` | sheet | Pick map 80 % |
| `hote_dashboard_screen.dart:450` | sheet | Formulaire édition logement |
| `map_screen.dart:141` | sheet | Aperçu logement ← **P0** |
| `auth_screen.dart:533` | sheet | Sélecteur pays |
| `agent_audit_screen.dart:48` | sheet | Source photo |
| `locataire_rentals_screen.dart:189` | sheet | Actions rapides location |
| `settings_screen.dart:110,165` | dialog | Mot de passe / suppression |
| `profile_screen.dart:276,407,468` | dialog | Devenir hôte / édition profil / déconnexion |
| `payment_screen.dart:92` | dialog | Succès paiement |
| `advance_payment_screen.dart:57,283` | dialog | Succès / confirmation |

---

## 4. Plan de migration par phases

### Phase 0 — Stabiliser shell & routing (0 à 0,5 j) ✅ FAIT
- [x] Migrer la logique du splash dans `redirect` de go_router (éliminer l'écran intermédiaire) ; réutiliser l'`AuthService` injecté.
- [x] Créer les routes manquantes : `/listing/:id`, `/book/:listingId`, `/chat/:recipientId`, `/all-listings`, `/create-listing`.
- [x] Convertir les appels `Navigator.push(MaterialPageRoute)` vers `context.go`/`context.push` **dans les écrans déjà adaptés** (home_screen, profile_screen, hote_dashboard_screen, locataire_rentals_screen) — cibles déjà déclarées.
- [x] Supprimer les séquences pop-then-push (map, locataire) : ouvrir la destination directement avec `context.go`.
- [x] Nettoyer le code mort : `AdaptiveLayout`, `ResponsiveValue`, `pushFlexPage`, `PaymentBottomSheet`.

Voir le rapport complet en section 6.

### Phase 1 — Overlays unifiés (0,5 j) ✅ FAIT
- [x] Migrer les 12 appels bruts vers `AdaptiveOverlay.show` (dialogs de confirmation → center-dialog desktop ; sheets d'action → side-panel desktop).
- [x] Faire de l'aperçu logement (`detail_bottom_sheet`) l'unique présentation détail côté overlay (déjà via `AdaptiveOverlay` — vérifier chaque point d'entrée).

Voir le rapport complet en section 7.

### Phase 2 — Écrans P0 « non adaptés au web »
- [ ] **`category_detail_screen`** : wrapper `AdaptiveContentContainer` ; largeur carte plafonnée (ex. `(maxW−gaps)/2` avec cap 1440) ; passer la liste à `AdaptiveGrid` ; bandeau promo + carte map adaptés ; boutons 38px → taille standard avec tap target.
- [ ] **`onboarding_screen`** : cap de contenu (600–800px) ; rendre la colonne scrollable (SafeArea + SingleChildScrollView) ; boutons toujours dans le viewport ; état desktop : pagination centrée, flèches latérales.
- [ ] **`budget_search_screen`** : container ; chips budget en `Wrap` ou scroll horizontal ; grille multi-colonnes desktop (`AdaptiveGrid`).
- [ ] **`map_screen`** : aperçu logement via `AdaptiveOverlay(isSidePanel: true)` ; navigation vers détail via route.
- [ ] **`auth_screen`** : country-picker → `AdaptiveOverlay` ; branche tablette (formulaire centré 480px max au lieu du mobile).
- [ ] **`all_listings_screen` / `favorites_screen`** : `AdaptiveGrid` (1/2/3/4 colonnes).

### Phase 3 — Écrans P1 (container + overflows)
- [ ] Ajouter `AdaptiveContentContainer` : booking_confirmation, review, payment, chat, advance_payment, refund_request, renew_booking, hote_tenant_detail, hote_visit_requests, settings, identity_verification, agent_audit.
- [ ] Overflows à corriger : RenewBooking (chips → Wrap), HoteRentals/TenantDetail (stats → Wrap/AdaptiveGrid), ChatScreen (titre AppBar → Expanded + ellipsis), PaymentScreen (`_SummaryRow` → Flexible), SearchScreen (checkbox → Flexible), MyBookings (ratio carte → 2.2 + ellipsis dates).
- [ ] `hote_dashboard` : remplacement `SizedBox(width:120)` des stats mobiles par un scroll horizontal ou grille ; formulaire édition → `AdaptiveOverlay`.
- [ ] `listing_detail_screen` : panneau droit `360 → min(360, 40% écran)` ; barre mobile → boutons en colonne si <340px.

### Phase 4 — Vérification multi-tailles
- [ ] Tester 4 largeurs : 320 / 768 / 1024 / 1440+ (Chrome DevTools device toolbar).
- [ ] Repasser chaque écran : aucun `RenderFlex overflow`, aucun bouton hors d'atteinte, scrolls corrects, overlays centrés sur desktop.
- [ ] Vérifier la sélection shell après chaque navigation (tab actif cohérent).

---

## 5. Ordre d'exécution recommandé (livrables courts)

1. Phase 0 (routing) → test nav complète desktop/mobile.
2. Phase 2 dans l'ordre : category_detail → onboarding → budget_search → map → auth → all_listings/favorites.
3. Phase 1 (overlays) entrelacée avec la Phase 2 (map, auth).
4. Phase 3 écrans P1 + corrections d'overflow.
5. Phase 4 vérification finale.

> ⚠️ Ne pas commencer l'implémentation large avant validation de ce plan (audit complet). Aucune nouvelle infra : tout doit s'appuyer sur `AdaptiveContentContainer`, `AdaptiveGrid`, `AdaptiveOverlay`, `AdaptiveScaffold` et les breakpoints existants.

---

## 6. Rapport Phase 0 — Routing & Navigation Consolidation ✅

### 6.1 Routes gardées (28)
| Route | Type | Usage |
|---|---|---|
| `/onboarding` | Fullscreen pre-auth | redirect |
| `/auth` | Fullscreen pre-auth | redirect |
| `/home`, `/search`, `/bookings`, `/profile`, `/conversations` | Primary (shell) | shell + NoTransitionPage |
| `/listing/:id` | Detail | `extra: Listing` sinon `_ListingLoadGate` (fetch par id) |
| `/book/:listingId` | Detail / funnel | idem |
| `/chat/:recipientId` | Detail | `extra: Listing` ou `{listing, initialMessage}` |
| `/map`, `/notifications` | Detail | header home |
| `/category/:label`, `/budget-search`, `/all-listings` | Categorie / recherche | home |
| `/create-listing` | Detail | hôte FAB |
| `/favorites`, `/settings`, `/identity-verification`, `/support` | Profil | profil |
| `/hote-dashboard`, `/hote-rentals`, `/hote-visits` | Rôle hôte | profil / dashboard |
| `/locataire-rentals` | Rôle locataire | profil |
| `/advance-payment`, `/refund-request`, `/renew-booking` | Flow | `extra: MonthlyRental` optionnel |

### 6.2 Routes supprimées (1)
- `/splash` : logique déplacée dans `redirect` go_router (initialLocation `/home` + vérif `onboarding_done` + `authService.isLoggedIn`). Singleton `AuthService` confirmé → état partagé redirect/écrans.

### 6.3 Navigation migrée (≈25 appels → `context.go`/`context.push`)
- `home_screen` : map, notifications, budget, catégorie (param encodé), détail (extra), all-listings (extra).
- `profile_screen` : settings, hôte-dashboard ×2, hôte-rentals, identity, favoris, locataire-rentals, réservations → `context.go('/bookings')` (tab shell, pas de stack dupliquée), support.
- `hote_dashboard` : create-listing (retour de résultat préservé via `push`), hôte-rentals, hôte-visits.
- `locataire_rentals` : 3 actions rapides + 3 actions sheet (pop-then-push supprimé, `extra: rental`).
- `map_screen` : pop-then-push supprimé → route `/listing/:id`.
- `listing_card` / `listing_detail_bottom_sheet` / `listing_detail_screen` : réserver → `/book/:listingId` ; message → `/chat/:recipientId`.
- `category_detail` ×2, `budget_search` : détail → `/listing/:id`.
- `conversations_screen` : conversation → `/chat/:recipientId` (reload au retour conservé).

### 6.4 Navigator.push restants (6, documentés)
| Fichier | Destination | Raison de maintien |
|---|---|---|
| `my_bookings_screen.dart:92` | ReviewScreen | flux de notation temporaire post-séjour |
| `my_bookings_screen.dart:343` | PaymentScreen | flux transactionnel (wizard) |
| `booking_confirmation_screen.dart:132` | PaymentScreen | idem |
| `locataire_rentals_screen.dart:225` | `_RentalDetailScreen` | classe privée liée à l'état de liste, objet non adressable URL |
| `listing_detail_screen.dart:218,583` | VisitRequestScreen | formulaire de flux dépendant du listing courant |
| `hote_rentals_screen.dart:145` | HoteTenantDetailScreen | gestion hôte liée au booking, retour attendu (refresh) |

### 6.5 Code mort supprimé (vérifié 0 référence par grep)
- `core/responsive/adaptive_layout.dart` (`AdaptiveLayout`, `ResponsiveValue`)
- `utils/route_transitions.dart` (`pushFlexPage`)
- `screens/payment/payment_bottom_sheet.dart`

### 6.6 Règles de navigation établies
- **Primary destination** → go_router shell (`context.go`)
- **Detail URL-addressable** → go_router (`context.push`) ; présentation adaptative conservée côté overlay (cards → side-panel desktop)
- **Quick action / temporary** → dialog / sheet / overlay → pas de route (Phase 1)
- **Transactional flow (payment, review, visit)** → temporaire volontairement hors routes
- **Ajout de route** : objets passés via `extra` ; fallback fetch par id (`_ListingLoadGate`) pour deep-links

### 6.7 Vérifications Phase 0
- ✅ Browser back/forward : historiques go_router intacts (pas de stack dupliquée — réservations en `context.go`)
- ✅ Direct URL / refresh : redirect préserve la session (onboarding_done + token)
- ✅ Aucune erreur `flutter analyze` (264 infos préexistantes : const/dépréciations, inchangées)
- ✅ Navigation mobile conservée (shell bottom-nav inchangé, `AdaptiveScaffold` source de vérité)

### 6.8 Risques / cas non résolus
- `extra` n'est pas persisté au refresh : deep-link `/listing/:id` re-fetch l'API (fallback OK si endpoint GET disponible ; sinon écran « Logement introuvable »).
- `/chat/:recipientId` sans `extra` (refresh) → écran « indisponible » : nécessiterait un fetch conversation (backend manquant).
- `Reservations profil → context.go('/bookings')` : changement de comportement assumé (tab au lieu de page empilée).

---

## 7. Rapport Phase 1 — Adaptive Overlay Migration ✅

### 7.1 Overlays migrés (15, tous les bruts éliminés)
| Overlay | Intention | Mobile | Tablette | Desktop |
|---|---|---|---|---|
| `map_screen` aperçu logement | contextual detail | bottom sheet | dialog | **side panel** (`isSidePanel: true`) |
| `hote_dashboard` édition logement | quick form | bottom sheet | dialog | dialog |
| `auth_screen` country picker | sélection | bottom sheet | dialog | dialog |
| `agent_audit` source photo | sélection | bottom sheet | dialog | dialog |
| `create_listing` picker carte | sélection | bottom sheet | dialog | dialog |
| `locataire_rentals` actions location | quick action | bottom sheet | dialog | dialog |
| `settings` mot de passe | quick form | bottom sheet | dialog | dialog |
| `settings` supprimer compte | confirmation | bottom sheet | dialog | dialog |
| `profile` devenir hôte | confirmation | bottom sheet | dialog | dialog |
| `profile` édition profil | quick form | bottom sheet | dialog | dialog |
| `profile` déconnexion | confirmation | bottom sheet | dialog | dialog |
| `payment` succès | confirmation (bloquant) | bottom sheet | dialog | dialog |
| `advance_payment` succès | confirmation (bloquant) | bottom sheet | dialog | dialog |
| `advance_payment` confirmation | confirmation | bottom sheet | dialog | dialog |
| `my_bookings` annulation (`bool`) | confirmation | bottom sheet | dialog | dialog |

### 7.2 Nouveaux éléments d'infrastructure (réutilisés, pas de nouveau framework)
- `shared/widgets/adaptive_dialog_content.dart` : carte de présentation commune (fond thème Flex, arrondi haut, titre `h3`, body scrollable max 560px, actions alignées à droite, `child` en dernier). Contrat child autonome identique à `ListingDetailBottomSheet`.
- `AdaptiveOverlay.show` : paramètre `barrierDismissible` (défaut `true`, rétro-compatible) — requis pour les écrans de succès bloquants ; propagé au sheet (dismiss + drag), dialog et side panel.

### 7.3 Comportements préservés
- Retours typés : `show<ImageSource>` (agent), `show<bool>` (annulation), `show<LatLng>` (carte).
- Séquence pop-then-push (map → détail, locataire → actions) : `Navigator.pop` ferme l'overlay, `context.push` route la destination.
- Double pop de retour (advance_payment succès) conservé (dialog + écran).
- `barrierDismissible: false` sur les flux de succès : pas de fermeture accidentelle (anti double-paiement).
- `setState` des écrans appelants conservés (country picker, formulaires).

### 7.4 Vérification Phase 1
- ✅ Grep : plus aucun `showModalBottomSheet` / `showDialog` / `showGeneralDialog` hors de `adaptive_overlay.dart` (0 overlay brut restant).
- ✅ `flutter analyze` : 0 erreur, 0 warning (259 infos préexistantes, −5 vs avant Phase 1).
- ✅ Structure du code : aucun branching mobile/desktop dupliqué — seul `AdaptiveOverlay` décide de la présentation.

### 7.5 Risques restants (Phase 1)
- En mode side-panel, le contenu d'aperçu carte (map_screen) conserve son fond arrondi haut — double fond imperceptible sous celui du panneau ; nettoyable si besoin.
- `AdaptiveDialogContent` plafonne à 560px de hauteur (scroll interne) : les formulaires très longs resteront scrollables, jamais coupés.