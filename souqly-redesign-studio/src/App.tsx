import React, { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { 
  Sparkles, 
  Layers, 
  Smartphone, 
  Copy, 
  Check, 
  ArrowLeft, 
  ArrowRight, 
  Search, 
  MapPin, 
  Heart, 
  Bell, 
  Plus, 
  MessageSquare, 
  User, 
  Settings, 
  FileText, 
  ChevronRight, 
  Code, 
  Phone, 
  Lock, 
  Sliders, 
  Globe, 
  Palette, 
  Eye, 
  Trash2, 
  CheckCircle2, 
  ExternalLink,
  MousePointer,
  Star,
  Zap,
  Grid
} from "lucide-react";

// Types for theme profiles
interface ThemeProfile {
  id: string;
  nameEn: string;
  nameAr: string;
  bgClass: string;
  cardClass: string;
  textPrimaryClass: string;
  textSecondaryClass: string;
  accentClass: string;
  accentTextClass: string;
  badgeClass: string;
  primaryHex: string;
  bgHex: string;
  accentHex: string;
  shadowClass: string;
  borderClass: string;
  description: string;
}

export default function App() {
  // Theme Configuration Store
  const themes: ThemeProfile[] = [
    {
      id: "eco-lux",
      nameEn: "Eco-Lux Emerald",
      nameAr: "الرقي البيئي المعاصر",
      bgClass: "bg-[#FAF9F6]",
      cardClass: "bg-white border border-[#EBEBE8]",
      textPrimaryClass: "text-[#1C1E21]",
      textSecondaryClass: "text-[#7A828A]",
      accentClass: "bg-[#1B4332] text-white hover:bg-[#2D6A4F]",
      accentTextClass: "text-[#2E6F40]",
      badgeClass: "bg-[#EAF4EC] text-[#2E6F40]",
      primaryHex: "0xFF1B4332",
      bgHex: "0xFFFAF9F6",
      accentHex: "0xFF2E6F40",
      shadowClass: "shadow-[0_8px_30px_rgb(27,67,50,0.03)]",
      borderClass: "border-[#EEEEEE]",
      description: "A premium, organic evolution of Sello's green and ivory identity. Perfect for a clean Arabic luxury catalog experience with soft drop shadows and warm margins.",
    },
    {
      id: "midnight-bento",
      nameEn: "Midnight Bento",
      nameAr: "المنظومة التقنية",
      bgClass: "bg-[#090B0D]",
      cardClass: "bg-[#111418] border border-[#1F252E]",
      textPrimaryClass: "text-[#ECEFF1]",
      textSecondaryClass: "text-[#6F7C85]",
      accentClass: "bg-[#00E676] text-[#050709] hover:bg-[#33ff99] font-bold",
      accentTextClass: "text-[#00E676]",
      badgeClass: "bg-[#112F24] text-[#00E676]",
      primaryHex: "0xFF00E676",
      bgHex: "0xFF090B0D",
      accentHex: "0xFF00B0FF",
      shadowClass: "shadow-[0_8px_30px_rgba(0,230,118,0.05)]",
      borderClass: "border-[#1F252E]",
      description: "Futuristic contrast of rich dark colors. Features high-tech bento grid cells, vibrant glowing neon-green overlays, and ultra-fluid element lines.",
    },
    {
      id: "nordic-alabaster",
      nameEn: "Brutalist Alabaster",
      nameAr: "الخطوط الإسكندنافية",
      bgClass: "bg-[#F3F4F6]",
      cardClass: "bg-white border-2 border-[#1A1A1A] shadow-[4px_4px_0px_0px_rgba(26,26,26,1)]",
      textPrimaryClass: "text-[#1A1A1A]",
      textSecondaryClass: "text-[#666666]",
      accentClass: "bg-[#1A1A1A] text-white hover:bg-neutral-800",
      accentTextClass: "text-black font-extrabold underline",
      badgeClass: "bg-[#E5E7EB] text-[#1A1A1A] border border-[#1A1A1A]",
      primaryHex: "0xFF1A1A1A",
      bgHex: "0xFFF3F4F6",
      accentHex: "0xFF1A1A1A",
      shadowClass: "",
      borderClass: "border-2 border-black",
      description: "High-contrast bold layout, solid borderlines, pixel-perfect aspect ratios, and rich negative space. Extremely modern, engaging, and readable.",
    },
    {
      id: "cupertino-glass",
      nameEn: "Cupertino Glass",
      nameAr: "الزجاجي الكوبرتيني",
      bgClass: "bg-gradient-to-tr from-[#E4E6EB] to-[#F0F2F5]",
      cardClass: "bg-white/70 backdrop-blur-xl border border-white/40 shadow-sm",
      textPrimaryClass: "text-[#1D1D1F]",
      textSecondaryClass: "text-[#86868B]",
      accentClass: "bg-gradient-to-r from-[#005F54] to-[#00897B] text-white hover:opacity-90",
      accentTextClass: "text-[#005F54]",
      badgeClass: "bg-white/80 text-[#005F54] border border-[#005F54]/10",
      primaryHex: "0xFF005F54",
      bgHex: "0xFFF0F2F5",
      accentHex: "0xFF00897B",
      shadowClass: "shadow-[0_12px_40px_rgba(0,0,0,0.03)]",
      borderClass: "border-[#E5E5EA]",
      description: "Ultra-luxury iOS-style glassmorphism. Light backdrop blurs, organic layered lighting, micro-hairline borders, and native Apple Feel physics.",
    }
  ];

  // State Management
  const [activeTheme, setActiveTheme] = useState<ThemeProfile>(themes[0]);
  const [activeSimulatorView, setActiveSimulatorView] = useState<string>("home");
  const [isRtl, setIsRtl] = useState<boolean>(true);
  const [stateManagement, setStateManagement] = useState<string>("BLoC");
  const [copiedPrompt, setCopiedPrompt] = useState<boolean>(false);
  const [copiedCodeCode, setCopiedCode] = useState<string | null>(null);
  
  // Custom interactive ad item definitions (matching translated Arabic original screenshots)
  const productAds = [
    {
      id: 1,
      titleAr: "شقة فاخرة في الجادرية",
      titleEn: "Luxury Apartment in Jadiriyah",
      price: "120,000,000 د.ع",
      locationAr: "بغداد، الجادرية",
      locationEn: "Baghdad, Al-Jadiriyah",
      timeAr: "منذ ساعتين",
      timeEn: "2 hours ago",
      image: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=500&q=80",
      badgeAr: "للبيع • سكني",
      badgeEn: "For Sale • Res",
    },
    {
      id: 2,
      titleAr: "مرسيدس E-Class 2023",
      titleEn: "Mercedes E-Class 2023",
      price: "75,000,000 د.ع",
      locationAr: "أربيل، عنكاوا",
      locationEn: "Erbil, Ankawa",
      timeAr: "منذ يوم واحد",
      timeEn: "1 day ago",
      image: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=500&q=80",
      badgeAr: "مستعمل • ممتاز",
      badgeEn: "Used • Mint",
    },
    {
      id: 3,
      titleAr: "كاميرا سوني A7IV",
      titleEn: "Sony A7IV Camera body",
      price: "3,500,000 د.ع",
      locationAr: "البصرة، حي الجزائر",
      locationEn: "Basra, Al-Jaza'ir",
      timeAr: "منذ ٣ أيام",
      timeEn: "3 days ago",
      image: "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=500&q=80",
      badgeAr: "الجرونج • جديد",
      badgeEn: "Electronics • New",
    }
  ];

  const categoryGrid = [
    { nameAr: "العقارات", nameEn: "Real Estate", icon: "🏢", subAr: "سكني، تجاري، أراضي", subEn: "Res, Comm, Lands" },
    { nameAr: "السيارات", nameEn: "Motors", icon: "🚗", subAr: "سيارات، دراجات، قطع غيار", subEn: "Cars, Bikes, Parts" },
    { nameAr: "الإلكترونيات", nameEn: "Electronics", icon: "📱", subAr: "هواتف، لابتوب، كاميرات", subEn: "Phones, Laptops, CAMs" },
    { nameAr: "السوق والمستعمل", nameEn: "Second Hand", icon: "🛍️", subAr: "أثاث، ملابس، أدوات", subEn: "Furniture, Fashion" },
    { nameAr: "دروس خصوصية", nameEn: "Tutoring", icon: "📚", subAr: "لغات، مناهج، مهارات", subEn: "Languages, Math" },
    { nameAr: "فرص العمل", nameEn: "Jobs", icon: "💼", subAr: "وظائف شاغرة، تدريب", subEn: "Vacancies, Intern" },
  ];

  const chatsList = [
    { name: "علي الحربي", avatar: "👨🏻‍💻", msg: "هل الشقة في الجادرية لا تزال متاحة؟", time: "٢٣ دقيقة", unread: true, online: true },
    { name: "زينب الموسوي", avatar: "👩🏻‍💼", msg: "هل يمكنني رؤية المزيد من صور السيارة مرسيدس؟", time: "ساعة واحدة", unread: false, online: true },
    { name: "أحمد سالم", avatar: "🧔🏻", msg: "تمام، نلتقي عند الساعة الخامسة مساءً لمعاينة الكاميرا.", time: "أمس", unread: false, online: false },
  ];

  // Dynamic Cursor Redesign Prompt Construction based on choices
  const generatedCursorPrompt = `You are a world-class Flutter expert using Cursor. Re-design our existing Arabic Marketplace Mobile App (called "Sello") to follow the new elegant ${activeTheme.nameEn} design direction with professional micro-architectures.

THEME DESIGN GUIDE FOR CURSOR:
- UI Theme Aesthetic: ${activeTheme.nameEn} (${activeTheme.nameAr})
- Color variables to inject:
  * Primary Brand Color: ${activeTheme.primaryHex}
  * Background Color: ${activeTheme.bgHex}
  * Accent Highlight: ${activeTheme.accentHex}
- Typography Family: 'Cairo' and 'Readex Pro' (beautiful premium Arabic fonts)
- Layout guidelines: ${activeTheme.description}
- State Management style: ${stateManagement}
- Directionality constraint: Handle dual RTL (Arabic) / LTR (English) gracefully in material routers.

ACTIONS REQUIRED IN FLUTTER:
1. Update 'lib/core/theme/app_colors.dart' with the hex color codes.
2. Ensure all UI cards utilize a uniform corner radius of BorderRadius.circular(20), thin hair-line borders in 0.05 opacity, and beautiful micro-shadows.
3. Replace standard AppBar layouts with integrated dynamic slivers containing the custom, beautiful search bar and flat status indicators.
4. Replace the bottom navigation bar with a beautiful floating nav bar that has glassmorphism backdrop filters in matching configurations: Use high backdrop blur of 12.0 sigma with white translucent boundaries.
5. Setup the dual-column bento grids in the main listings explorer ('lib/screens/home/home_screen.dart') and format prices perfectly with local comma-grouped IQD (د.ع) formatting.
6. Provide rich tactile feed-backs on lists tapping and cards long-hold.

Please generate the file implementations step-by-step and write clean, structured dart code without placeholder omissions.`;

  const copyPromptToClipboard = () => {
    navigator.clipboard.writeText(generatedCursorPrompt);
    setCopiedPrompt(true);
    setTimeout(() => setCopiedPrompt(false), 2500);
  };

  const copyWidgetCode = (code: string, id: string) => {
    navigator.clipboard.writeText(code);
    setCopiedCode(id);
    setTimeout(() => setCopiedCode(null), 2000);
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 font-sans antialiased text-sm">
      {/* Top Professional Admin Bar */}
      <header className="bg-white text-slate-900 py-5 px-6 shadow-sm border-b border-slate-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-indigo-600 rounded-lg flex items-center justify-center shadow-sm">
              <div className="w-4 h-4 bg-white rounded-sm"></div>
            </div>
            <div>
              <h1 className="text-lg font-bold tracking-tight text-slate-900 flex items-center gap-2">
                Sello • Redesign Studio
                <span className="text-xs bg-indigo-50 text-indigo-700 px-3 py-0.5 rounded-full font-semibold border border-indigo-100">
                  Professional Polish Lab
                </span>
              </h1>
              <p className="text-xs text-slate-500">
                Generate high-fidelity UI directions, prompts, and design token configurations for your marketplace app
              </p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <a 
              href="#prompt-section" 
              className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-xl text-xs font-semibold flex items-center gap-2 transition-all shadow-sm cursor-pointer"
            >
              <Code className="w-4 h-4" />
              <span>Copy Cursor Prompt</span>
            </a>
            <div className="text-xs text-slate-500 border-l border-slate-200 pl-4 py-1 flex items-center gap-1.5">
              <span>Blueprint:</span>
              <code className="text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded text-[11px] font-mono border border-indigo-100 font-medium">/design.md</code>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content Workspace Layout Grid */}
      <main className="max-w-7xl mx-auto p-4 md:p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        {/* LEFT COLUMN: Style Config & Controls (col-span-4) */}
        <div className="lg:col-span-4 flex flex-col gap-6">
          
          {/* Quick Stats & Core Concept Overview */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
            <h2 className="text-slate-800 font-bold text-base mb-2 flex items-center gap-2">
              <Sliders className="w-4 h-4 text-indigo-600" />
              <span>System Overhaul Blueprint</span>
            </h2>
            <p className="text-xs text-slate-500 leading-relaxed mb-4">
              Upload your raw wireframes or design elements (like the 11 screenshots of Sello) and use this tool to compile beautiful visual tokens. Instantly transform basic borders, flat tables, and gray shadow layouts into sophisticated UI.
            </p>
            
            <div className="grid grid-cols-2 gap-2 text-xs">
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <div className="text-slate-400 font-medium">Source App</div>
                <div className="text-slate-800 font-bold mt-0.5">Sello</div>
              </div>
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <div className="text-slate-400 font-medium">Region Target</div>
                <div className="text-slate-800 font-bold mt-0.5 flex items-center gap-1">
                  <span>Iraq</span>
                  <span className="text-[10px] bg-slate-200 text-slate-600 px-1 py-0.5 rounded font-mono">Basra / IQD</span>
                </div>
              </div>
            </div>
          </div>

          {/* Theme Archetype Select Group */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
            <h3 className="text-slate-800 font-bold text-sm mb-4 flex items-center gap-2">
              <Palette className="w-4 h-4 text-indigo-600" />
              <span>Choose Your Re-design Archetype</span>
            </h3>
            
            <div className="flex flex-col gap-3">
              {themes.map((theme) => {
                const isActive = activeTheme.id === theme.id;
                return (
                  <button
                    key={theme.id}
                    onClick={() => setActiveTheme(theme)}
                    className={`w-full text-left p-4 rounded-xl transition-all cursor-pointer flex gap-3.5 border text-xs leading-normal ${
                      isActive 
                        ? "bg-indigo-50/70 text-slate-900 border-indigo-200 shadow-sm" 
                        : "bg-white text-slate-700 hover:bg-slate-50 border-slate-200"
                    }`}
                  >
                    <div className="text-2xl mt-0.5 flex items-center justify-center">
                      {theme.id === "eco-lux" && "🌿"}
                      {theme.id === "midnight-bento" && "🌌"}
                      {theme.id === "nordic-alabaster" && "🍶"}
                      {theme.id === "cupertino-glass" && "💫"}
                    </div>
                    <div className="flex-grow">
                      <div className="flex items-center justify-between gap-2">
                        <span className={`font-bold text-sm ${isActive ? "text-indigo-950 font-black" : "text-slate-800"}`}>{theme.nameEn}</span>
                        <span className={`font-semibold text-xs ${isActive ? "text-indigo-700" : "text-slate-500"}`}>
                          {theme.nameAr}
                        </span>
                      </div>
                      <p className={`text-[11px] mt-1 line-clamp-2 leading-relaxed ${isActive ? "text-slate-600" : "text-slate-400"}`}>
                        {theme.description}
                      </p>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Prompt Refiner Customizations */}
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
            <h3 className="text-slate-800 font-bold text-sm mb-3.5 flex items-center gap-2">
              <Sliders className="w-4 h-4 text-indigo-600" />
              <span>Refine Engine Settings</span>
            </h3>

            <div className="space-y-4">
              {/* Flutter State Management Dropdown */}
              <div>
                <label className="block text-slate-500 font-semibold mb-1.5 text-xs">State Management Style</label>
                <div className="grid grid-cols-3 gap-1 bg-slate-100 p-1 rounded-xl">
                  {["BLoC", "Riverpod", "Provider"].map((st) => (
                    <button
                      key={st}
                      onClick={() => setStateManagement(st)}
                      className={`py-1.5 text-xs rounded-lg font-bold transition-all cursor-pointer ${
                        stateManagement === st 
                          ? "bg-white text-indigo-700 shadow-sm border border-slate-200/40" 
                          : "text-slate-500 hover:text-slate-800"
                      }`}
                    >
                      {st}
                    </button>
                  ))}
                </div>
              </div>

              {/* RTL Simulator Setting Toggle */}
              <div>
                <label className="block text-slate-500 font-semibold mb-1.5 text-xs">Mockup View Language</label>
                <div className="grid grid-cols-2 gap-1 bg-slate-100 p-1 rounded-xl">
                  <button
                    onClick={() => setIsRtl(true)}
                    className={`py-1.5 text-xs rounded-lg transition-all cursor-pointer flex items-center justify-center gap-1 ${
                      isRtl 
                        ? "bg-white text-indigo-700 shadow-sm font-bold border border-slate-200/40" 
                        : "text-slate-500 hover:text-slate-800"
                    }`}
                  >
                    <span>Arabic (RTL)</span>
                    <span className="text-[10px] opacity-75">Sello</span>
                  </button>
                  <button
                    onClick={() => setIsRtl(false)}
                    className={`py-1.5 text-xs rounded-lg transition-all cursor-pointer flex items-center justify-center gap-1 ${
                      !isRtl 
                        ? "bg-white text-indigo-700 shadow-sm font-bold border border-slate-200/40" 
                        : "text-slate-500 hover:text-slate-800"
                    }`}
                  >
                    <span>English (LTR)</span>
                    <span className="text-[10px] opacity-75">Sello</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Interactive Redesign Audit Tips */}
          <div className="p-6 bg-slate-900 text-white rounded-2xl shadow-lg border border-slate-800 relative overflow-hidden">
            <div className="absolute right-0 top-0 w-24 h-24 bg-indigo-500/10 rounded-full blur-xl pointer-events-none" />
            <h4 className="text-indigo-300 font-bold text-sm mb-3.5 flex items-center gap-1.5">
              <Zap className="w-4 h-4 text-indigo-400" />
              <span>Redesign Insights (نقاط مراجعة التصميم)</span>
            </h4>
            <ul className="space-y-4 text-xs text-slate-300 leading-normal">
              <li className="flex gap-2.5">
                <span className="text-indigo-400 text-base font-bold">✓</span>
                <div>
                  <strong className="text-white block font-medium">Overhaul Heavy Outline Borders</strong>
                  <span className="text-slate-400 text-[11px]">We replaced your dark gray card frames with hairline borders and ambient soft-lighting shadows (0.03 opacity).</span>
                </div>
              </li>
              <li className="flex gap-2.5">
                <span className="text-indigo-400 text-base font-bold">✓</span>
                <div>
                  <strong className="text-white block font-medium">Bento Grids instead of Flat Rows</strong>
                  <span className="text-slate-400 text-[11px]">Your categories select screen and listings page now use dual-height grids to look high-end and luxurious.</span>
                </div>
              </li>
              <li className="flex gap-2.5">
                <span className="text-indigo-400 text-base font-bold">✓</span>
                <div>
                  <strong className="text-white block font-medium">Advanced Floating Navigation Bar</strong>
                  <span className="text-slate-400 text-[11px]">Floating glass design reduces system margin noise and makes bottom-clicks fluid.</span>
                </div>
              </li>
            </ul>
          </div>

        </div>

        {/* MIDDLE COLUMN: High-Fidelity Mobile App Simulator (col-span-5) */}
        <div className="lg:col-span-5 flex flex-col items-center justify-start gap-4">
          
          <div className="w-full flex items-center justify-between text-xs px-2">
            <span className="text-slate-400 font-bold tracking-wider uppercase">REDESIGN PREVIEW STUDIO</span>
            <div className="flex gap-1 bg-slate-100 p-1 rounded-xl border border-slate-200">
              <button 
                onClick={() => setActiveSimulatorView("home")}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer ${activeSimulatorView === "home" ? "bg-white text-indigo-700 shadow-sm border border-slate-200/40" : "text-slate-500 hover:text-slate-700 hover:bg-slate-50/50"}`}
              >
                الرئيسية
              </button>
              <button 
                onClick={() => setActiveSimulatorView("categories")}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer ${activeSimulatorView === "categories" ? "bg-white text-indigo-700 shadow-sm border border-slate-200/40" : "text-slate-500 hover:text-slate-700 hover:bg-slate-50/50"}`}
              >
                الفئات
              </button>
              <button 
                onClick={() => setActiveSimulatorView("chats")}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer ${activeSimulatorView === "chats" ? "bg-white text-indigo-700 shadow-sm border border-slate-200/40" : "text-slate-500 hover:text-slate-700 hover:bg-slate-50/50"}`}
              >
                الدردشة
              </button>
              <button 
                onClick={() => setActiveSimulatorView("profile")}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer ${activeSimulatorView === "profile" ? "bg-white text-indigo-700 shadow-sm border border-slate-200/40" : "text-slate-500 hover:text-slate-700 hover:bg-slate-50/50"}`}
              >
                حسابي
              </button>
              <button 
                onClick={() => setActiveSimulatorView("login")}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer ${activeSimulatorView === "login" ? "bg-white text-indigo-700 shadow-sm border border-slate-200/40 relative" : "text-slate-500 hover:text-slate-700 hover:bg-slate-50/50"}`}
              >
                تسجيل
              </button>
            </div>
          </div>

          {/* The Phone Case Box Container */}
          <div className="relative w-full max-w-[385px] h-[780px] bg-slate-950 rounded-[50px] p-3.5 shadow-2xl border-4 border-slate-800 grid relative ring-12 ring-indigo-950/20">
            {/* Dynamic Ambient Blur Glow behind the device */}
            <div className={`absolute inset-0 bg-indigo-500/10 blur-[120px] rounded-[50px] transition-all duration-700 pointer-events-none -z-10`} />
            
            {/* Speaker Grille/Dynamic Island */}
            <div className="absolute top-5 left-1/2 -translate-x-1/2 w-28 h-5 bg-slate-950 rounded-full z-40 flex items-center justify-center">
              <div className="w-1.5 h-1.5 bg-slate-800 rounded-full absolute left-4" />
              <div className="w-12 h-1 bg-slate-800 rounded-full absolute" />
            </div>

            {/* Inner Display Screen */}
            <div className={`relative h-full w-full rounded-[38px] overflow-hidden flex flex-col justify-between transition-all duration-500 ${activeTheme.bgClass} ${isRtl ? "text-right" : "text-left"}`}>
              
              {/* Header Status Bar Spacer */}
              <div className="pt-8 px-5 flex items-center justify-between text-[11px] font-semibold text-slate-400 z-30 select-none">
                <span>9:41</span>
                <div className="flex items-center gap-1.5">
                  <span>5G</span>
                  <div className="w-4 h-2.5 border border-slate-400 rounded-sm p-0.5 flex items-center"><div className="bg-slate-400 h-full w-2" /></div>
                </div>
              </div>

              {/* Dynamic Screen View Renderer */}
              <div className="flex-1 overflow-y-auto px-4 py-2 scrollbar-none pb-20">
                <AnimatePresence mode="wait">
                  
                  {/* ====== HOME FEED VIEW ====== */}
                  {activeSimulatorView === "home" && (
                    <motion.div
                      key="feed"
                      initial={{ opacity: 0, y: 15 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -15 }}
                      className="space-y-4"
                    >
                      {/* Top App Header bar */}
                      <div className="flex items-center justify-between pt-1">
                        <div className="flex items-center gap-2">
                          <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm ${activeTheme.badgeClass}`}>
                            س
                          </div>
                          <div>
                            <h4 className={`font-black text-sm tracking-tight ${activeTheme.textPrimaryClass}`}>Sello</h4>
                            <p className="text-[10px] text-slate-400 font-medium">البصرة، العراق</p>
                          </div>
                        </div>
                        <div className={`p-2 rounded-full cursor-pointer relative ${activeTheme.cardClass}`}>
                          <Bell className="w-3.5 h-3.5 text-slate-600" />
                          <span className="absolute top-1 right-1 w-1.5 h-1.5 bg-amber-500 rounded-full" />
                        </div>
                      </div>

                      {/* Overhauled Search Box */}
                      <div className="relative">
                        <input 
                          type="text" 
                          placeholder={isRtl ? "ابحث عن سيارات، شقق، إلكترونيات..." : "Search cars, apartments, electronics..."}
                          className={`w-full py-2.5 pl-4 pr-10 rounded-2xl outline-none text-xs ${activeTheme.cardClass}`}
                          disabled
                        />
                        <Search className={`w-4 h-4 absolute top-3 ${isRtl ? "left-4" : "right-4"} text-slate-400`} />
                      </div>

                      {/* Premium Horizontal Categories bar */}
                      <div>
                        <div className="flex items-center justify-between mb-2">
                          <span className={`font-bold text-xs ${activeTheme.textPrimaryClass}`}>
                            {isRtl ? "تصفح الفئات" : "Explore Categories"}
                          </span>
                          <span className="text-[10px] text-emerald-600 cursor-pointer">{isRtl ? "عرض الكل" : "View All"}</span>
                        </div>
                        <div className={`flex gap-2 overflow-x-auto pb-1 scrollbar-none ${isRtl ? "flex-row-reverse" : "flex-row"}`}>
                          {[
                            { nameAr: "عقارات", nameEn: "Real Estate", icon: "🏢" },
                            { nameAr: "سيارات", nameEn: "Motors", icon: "🚗" },
                            { nameAr: "إلكترونيات", nameEn: "Devices", icon: "📱" },
                            { nameAr: "مستعمل", nameEn: "Secondhand", icon: "🛍️" },
                          ].map((cat, i) => (
                            <div 
                              key={i} 
                              className={`px-3 py-2 rounded-xl text-xs font-bold whitespace-nowrap cursor-pointer flex items-center gap-1 transition-all ${
                                i === 0 ? activeTheme.accentClass : activeTheme.cardClass
                              }`}
                            >
                              <span>{cat.icon}</span>
                              <span>{isRtl ? cat.nameAr : cat.nameEn}</span>
                            </div>
                          ))}
                        </div>
                      </div>

                      {/* Overhauled Dual Column Bento Listing Grid */}
                      <div>
                        <h4 className={`font-bold text-xs mb-2.5 ${activeTheme.textPrimaryClass}`}>
                          {isRtl ? "أحدث النشرات والمعروضات" : "Featured Listings"}
                        </h4>
                        
                        <div className="grid grid-cols-2 gap-3">
                          {productAds.map((ad) => (
                            <div 
                              key={ad.id}
                              className={`rounded-2xl overflow-hidden transition-all duration-300 hover:scale-[1.02] flex flex-col ${activeTheme.cardClass} ${activeTheme.shadowClass}`}
                            >
                              {/* Picture Stack */}
                              <div className="relative h-28 w-full bg-slate-100">
                                <img src={ad.image} alt={ad.titleEn} className="w-full h-full object-cover" />
                                <span className={`absolute top-2 left-2 text-[8px] px-1.5 py-0.5 rounded-md font-bold tracking-wide ${activeTheme.badgeClass}`}>
                                  {isRtl ? ad.badgeAr : ad.badgeEn}
                                </span>
                                <button className="absolute top-2 right-2 bg-white/90 p-1.5 rounded-full text-[#E63946] shadow-sm">
                                  <Heart className="w-3 h-3 fill-rose-500 stroke-rose-500" />
                                </button>
                              </div>

                              {/* ad details body */}
                              <div className="p-2.5 flex-1 flex flex-col justify-between">
                                <div>
                                  <h5 className={`font-bold text-[11px] line-clamp-1 ${activeTheme.textPrimaryClass}`}>
                                    {isRtl ? ad.titleAr : ad.titleEn}
                                  </h5>
                                  <p className="text-[#38a169] text-xs font-extrabold mt-1">{ad.price}</p>
                                </div>
                                <div className="mt-2 pt-2 border-t border-slate-100/50 flex items-center justify-between text-[9px] text-slate-400 font-medium">
                                  <span className="flex items-center gap-0.5 truncate">
                                    <MapPin className="w-2.5 h-2.5 text-slate-400" />
                                    <span className="truncate">{isRtl ? ad.locationAr : ad.locationEn}</span>
                                  </span>
                                </div>
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>

                    </motion.div>
                  )}

                  {/* ====== CATEGORIES SCREEN VIEW ====== */}
                  {activeSimulatorView === "categories" && (
                    <motion.div
                      key="categories"
                      initial={{ opacity: 0, y: 15 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -15 }}
                      className="space-y-4"
                    >
                      <div className="pt-1">
                        <h3 className={`font-black text-base ${activeTheme.textPrimaryClass}`}>
                          {isRtl ? "اختر الفئة الرئيسية" : "Choose Main Category"}
                        </h3>
                        <p className="text-[10px] text-slate-400">{isRtl ? "Sello • دليل العراق الشامل" : "Sello • Iraq Directory"}</p>
                      </div>

                      {/* Bento categories block list */}
                      <div className="grid grid-cols-2 gap-3.5">
                        {categoryGrid.map((cat, i) => (
                          <div 
                            key={i} 
                            className={`p-4 rounded-2xl cursor-pointer hover:border-emerald-500/30 transition-all text-left flex flex-col justify-between h-28 ${activeTheme.cardClass} ${activeTheme.shadowClass}`}
                          >
                            <span className="text-xl bg-slate-100 dark:bg-slate-800/10 w-9 h-9 rounded-xl flex items-center justify-center mb-2">
                              {cat.icon}
                            </span>
                            <div>
                              <h5 className={`font-bold text-xs ${activeTheme.textPrimaryClass}`}>
                                {isRtl ? cat.nameAr : cat.nameEn}
                              </h5>
                              <p className="text-[9px] text-slate-400 mt-0.5 truncate">
                                {isRtl ? cat.subAr : cat.subEn}
                              </p>
                            </div>
                          </div>
                        ))}
                      </div>

                    </motion.div>
                  )}

                  {/* ====== CHATS INBOX VIEW ====== */}
                  {activeSimulatorView === "chats" && (
                    <motion.div
                      key="chats"
                      initial={{ opacity: 0, y: 15 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -15 }}
                      className="space-y-4"
                    >
                      <div className="pt-1 flex items-center justify-between">
                        <div>
                          <h3 className={`font-black text-base ${activeTheme.textPrimaryClass}`}>
                            {isRtl ? "الرسائل والمحادثات" : "Messages"}
                          </h3>
                          <p className="text-[10px] text-slate-400">{isRtl ? "تواصل مباشرة مع المشترين والبائعين" : "Direct chat with buyers"}</p>
                        </div>
                        <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold ${activeTheme.badgeClass}`}>
                          {isRtl ? "٢ نشط" : "2 Active"}
                        </span>
                      </div>

                      {/* Online Users Bubbles row */}
                      <div className={`flex gap-3 overflow-x-auto pb-1.5 scrollbar-none ${isRtl ? "flex-row-reverse" : "flex-row"}`}>
                        {[
                          { name: "أبو علي", avatar: "🧔🏻" },
                          { name: "فاطمة", avatar: "👩🏻" },
                          { name: "زيد", avatar: "👱🏻‍♂️" },
                          { name: "حسين", avatar: "👨🏻" },
                          { name: "رشا", avatar: "👧🏻" },
                        ].map((user, i) => (
                          <div key={i} className="flex flex-col items-center gap-1 shrink-0 cursor-pointer">
                            <div className="relative w-11 h-11 rounded-full bg-slate-100 border-2 border-emerald-500 flex items-center justify-center text-xl">
                              {user.avatar}
                              <span className="absolute bottom-0 right-0 w-3 h-3 bg-emerald-500 border-2 border-white rounded-full" />
                            </div>
                            <span className="text-[9px] text-slate-500 font-medium">{user.name}</span>
                          </div>
                        ))}
                      </div>

                      {/* Conversations Vertical Inbox List */}
                      <div className="space-y-2.5">
                        {chatsList.map((chat, i) => (
                          <div 
                            key={i} 
                            className={`p-3 rounded-2xl transition-all cursor-pointer flex gap-3 items-center hover:bg-slate-100/50 ${activeTheme.cardClass}`}
                          >
                            <div className="relative w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-xl">
                              {chat.avatar}
                              {chat.online && (
                                <span className="absolute bottom-0 right-0 w-2.5 h-2.5 bg-emerald-500 border-2 border-white rounded-full" />
                              )}
                            </div>
                            <div className="flex-1 min-w-0">
                              <div className="flex items-center justify-between gap-1">
                                <h5 className={`font-bold text-xs ${activeTheme.textPrimaryClass}`}>{chat.name}</h5>
                                <span className="text-[9px] text-slate-400 shrink-0">{chat.time}</span>
                              </div>
                              <p className="text-[10px] text-slate-500 truncate mt-0.5">
                                {chat.msg}
                              </p>
                            </div>
                            {chat.unread && (
                              <span className="w-2.5 h-2.5 bg-emerald-500 rounded-full shrink-0" />
                            )}
                          </div>
                        ))}
                      </div>

                    </motion.div>
                  )}

                  {/* ====== PROFILE SCREEN VIEW ====== */}
                  {activeSimulatorView === "profile" && (
                    <motion.div
                      key="profile"
                      initial={{ opacity: 0, y: 15 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -15 }}
                      className="space-y-4"
                    >
                      {/* Premium User Info Block */}
                      <div className={`p-4 rounded-3xl text-center flex flex-col items-center justify-center ${activeTheme.cardClass} ${activeTheme.shadowClass}`}>
                        <div className="relative mb-3">
                          <div className="w-16 h-16 rounded-full bg-slate-100 text-3xl flex items-center justify-center border-4 border-emerald-500/10">
                            👨🏻‍💼
                          </div>
                          <button className="absolute bottom-0 right-0 bg-[#1B4332] text-white p-1 rounded-full border-2 border-white shadow">
                            <Settings className="w-3.5 h-3.5" />
                          </button>
                        </div>
                        <h4 className={`font-black text-sm ${activeTheme.textPrimaryClass}`}>حسام العراقي</h4>
                        <p className="text-[10px] text-slate-400 font-medium mt-0.5">بغداد، الكرادة</p>

                        {/* Marketplace Metrics row */}
                        <div className="grid grid-cols-3 gap-2 w-full mt-4 pt-4 border-t border-slate-100">
                          <div>
                            <span className={`font-black text-xs block ${activeTheme.textPrimaryClass}`}>٢٥</span>
                            <span className="text-[9px] text-slate-500">{isRtl ? "إعلان" : "Ads"}</span>
                          </div>
                          <div className="border-x border-slate-100">
                            <span className={`font-black text-xs block ${activeTheme.textPrimaryClass}`}>١.٥ ألف</span>
                            <span className="text-[9px] text-slate-500">{isRtl ? "مشاهدة" : "Views"}</span>
                          </div>
                          <div>
                            <span className={`font-black text-xs block ${activeTheme.textPrimaryClass}`}>١٢٠</span>
                            <span className="text-[9px] text-slate-500">{isRtl ? "متابع" : "Followers"}</span>
                          </div>
                        </div>
                      </div>

                      {/* Interactive Section Options */}
                      <div className="space-y-2">
                        {[
                          { titleAr: "إعلاناتي المعروضة", titleEn: "My Live Ads", icon: "📋", count: "٦" },
                          { titleAr: "قائمة المفضلة لدي", titleEn: "My Favorites List", icon: "❤️", count: "١٢" },
                          { titleAr: "تعديل بيانات الحساب", titleEn: "Account Preferences", icon: "👤", count: null },
                          { titleAr: "تغيير لغة التطبيق", titleEn: "Change Language", icon: "🌐", count: "العربية" },
                        ].map((opt, i) => (
                          <div 
                            key={i} 
                            className={`p-3 rounded-2xl cursor-pointer hover:bg-slate-100/30 flex items-center justify-between ${activeTheme.cardClass}`}
                          >
                            <div className="flex items-center gap-3">
                              <span className="text-sm">{opt.icon}</span>
                              <span className={`font-bold text-xs ${activeTheme.textPrimaryClass}`}>
                                {isRtl ? opt.titleAr : opt.titleEn}
                              </span>
                            </div>
                            <div className="flex items-center gap-1 text-[10px] text-slate-400">
                              {opt.count && <span className={`px-2 py-0.5 rounded-full ${activeTheme.badgeClass}`}>{opt.count}</span>}
                              <ChevronRight className="w-3" />
                            </div>
                          </div>
                        ))}
                      </div>

                    </motion.div>
                  )}

                  {/* ====== OTP / LOGIN SCREEN ====== */}
                  {activeSimulatorView === "login" && (
                    <motion.div
                      key="login"
                      initial={{ opacity: 0, y: 15 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -15 }}
                      className="space-y-6 pt-2"
                    >
                      {/* Logo and Greeting Header */}
                      <div className="text-center space-y-2">
                        <div className="mx-auto w-12 h-12 bg-[#1B4332] rounded-2xl flex items-center justify-center text-white text-2xl shadow-md">
                          🏪
                        </div>
                        <h3 className={`font-black text-base ${activeTheme.textPrimaryClass}`}>Sello • تسجيل الدخول</h3>
                        <p className="text-[10px] text-slate-500 leading-normal leading-relaxed">
                          {isRtl ? "أدخل رقم الهاتف للحصول على رمز التفعيل والدخول الآمن" : "Enter phone for OTP validation code"}
                        </p>
                      </div>

                      {/* Phone Code input mimic */}
                      <div className="space-y-3">
                        <div className="relative">
                          <label className="block text-[10px] text-slate-400 font-extrabold mb-1">{isRtl ? "رقم الهاتف" : "Phone Number"}</label>
                          <div className={`flex items-center rounded-2xl px-3 py-2.5 gap-2 ${activeTheme.cardClass}`}>
                            <span className="text-xs font-bold text-slate-700 select-none flex items-center gap-1 border-r pr-2">
                              🇮🇶 +964
                            </span>
                            <input 
                              type="text" 
                              placeholder="7901234567" 
                              className="text-xs bg-transparent outline-none flex-1 font-bold tracking-wider"
                              disabled
                            />
                            <Phone className="w-3.5 h-3.5 text-slate-400" />
                          </div>
                        </div>

                        {/* Send Code CTA action button styled with gradient */}
                        <button className={`w-full py-3 rounded-2xl font-black text-xs transition-all cursor-pointer shadow-md ${activeTheme.accentClass}`}>
                          {isRtl ? "إرسال رمز التفعيل" : "Send Activation Code"}
                        </button>
                      </div>

                      <div className="relative flex py-2 items-center text-[10px] text-slate-400">
                        <div className="flex-grow border-t border-slate-200"></div>
                        <span className="flex-shrink mx-4 text-slate-400 font-bold">{isRtl ? "أو بواسطة" : "OR VIA"}</span>
                        <div className="flex-grow border-t border-slate-200"></div>
                      </div>

                      {/* Google Authentication alternative button */}
                      <button className={`w-full py-2.5 rounded-2xl font-bold text-xs cursor-pointer flex items-center justify-center gap-2 border ${activeTheme.cardClass}`}>
                        <span className="text-base">G</span>
                        <span>{isRtl ? "الدخول بحساب Google" : "Continue with Google"}</span>
                      </button>

                    </motion.div>
                  )}

                </AnimatePresence>
              </div>

              {/* FLOATING NAVIGATION GLASS FOOTER METRIC (FloatingGlassNavBar simulation) */}
              <div className="absolute bottom-3 left-0 right-0 px-3 z-30 select-none">
                <div className={`h-14 w-full rounded-2xl flex items-center justify-around px-2 backdrop-blur-xl border border-white/20 transition-all ${
                  activeTheme.id === "eco-lux" ? "bg-white/94 shadow-lg border-slate-100" : ""
                } ${
                  activeTheme.id === "midnight-bento" ? "bg-[#111418]/90 shadow-2xl border-slate-800" : ""
                } ${
                  activeTheme.id === "nordic-alabaster" ? "bg-white border-2 border-black" : ""
                } ${
                  activeTheme.id === "cupertino-glass" ? "bg-white/60 shadow border-white/40" : ""
                }`}>
                  
                  {/* Nav links */}
                  <div 
                    onClick={() => setActiveSimulatorView("home")}
                    className={`flex flex-col items-center gap-0.5 cursor-pointer transition-all ${activeSimulatorView === "home" ? activeTheme.accentTextClass : "text-slate-400"}`}
                  >
                    <Smartphone className="w-4 h-4" />
                    <span className="text-[8px] font-bold">{isRtl ? "الرئيسية" : "Home"}</span>
                  </div>

                  <div 
                    onClick={() => setActiveSimulatorView("categories")}
                    className={`flex flex-col items-center gap-0.5 cursor-pointer transition-all ${activeSimulatorView === "categories" ? activeTheme.accentTextClass : "text-slate-400"}`}
                  >
                    <Grid className="w-4 h-4" />
                    <span className="text-[8px] font-bold">{isRtl ? "الأقسام" : "Categories"}</span>
                  </div>

                  {/* Center Add Ad Circle */}
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center text-white font-heavy text-base cursor-pointer transform -translate-y-2.5 transition-all shadow-md ${
                    activeTheme.id === "nordic-alabaster" ? "bg-black border-2 border-black -translate-y-0.5" : "bg-gradient-to-tr from-[#1B4332] to-[#2D6A4F]"
                  }`}>
                    <Plus className="w-5 h-5 stroke-[3px]" />
                  </div>

                  <div 
                    onClick={() => setActiveSimulatorView("chats")}
                    className={`flex flex-col items-center gap-0.5 cursor-pointer transition-all ${activeSimulatorView === "chats" ? activeTheme.accentTextClass : "text-slate-400"}`}
                  >
                    <MessageSquare className="w-4 h-4" />
                    <span className="text-[8px] font-bold">{isRtl ? "الدردشة" : "Inbox"}</span>
                  </div>

                  <div 
                    onClick={() => setActiveSimulatorView("profile")}
                    className={`flex flex-col items-center gap-0.5 cursor-pointer transition-all ${activeSimulatorView === "profile" ? activeTheme.accentTextClass : "text-slate-400"}`}
                  >
                    <User className="w-4 h-4" />
                    <span className="text-[8px] font-bold">{isRtl ? "حسابي" : "Profile"}</span>
                  </div>

                </div>
              </div>

            </div>
          </div>

        </div>

        {/* RIGHT COLUMN: Code Viewers & Interactive Widget Library (col-span-3) */}
        <div className="lg:col-span-3 flex flex-col gap-6">
          
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200">
            <h3 className="text-slate-800 font-bold text-sm mb-1.5 flex items-center gap-2">
              <Code className="w-4 h-4 text-indigo-600" />
              <span>Interactive Flutter Widgets</span>
            </h3>
            <p className="text-xs text-slate-500 mb-4 leading-relaxed">
              Here are reusable snippets tailored dynamically to your chosen archetype. Copy and insert them directly into your Flutter workspace inside Cursor relative paths.
            </p>

            <div className="space-y-4">
              {/* Token Card Widget */}
              <div className="bg-slate-50 rounded-2xl p-4 border border-slate-200/60 relative">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-[10px] font-mono text-slate-400 font-bold">AppColors Palette Configuration</span>
                  <button 
                    onClick={() => copyWidgetCode(`class AppColors {
  static const Color background = Color(${activeTheme.primaryHex});
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1C1E21);
  static const Color primaryGradStart = Color(0xFF1B4332);
}`, "colors")}
                    className="text-slate-500 hover:text-slate-800 p-1.5 rounded hover:bg-slate-200/50 cursor-pointer transition-all"
                  >
                    {copiedCodeCode === "colors" ? <Check className="w-3.5 h-3.5 text-indigo-600 animate-pulse" /> : <Copy className="w-3.5 h-3.5" />}
                  </button>
                </div>
                <pre className="text-[10px] font-mono text-slate-600 overflow-x-auto whitespace-pre leading-normal">
                  {`// app_colors.dart
class AppColors {
  static const primary = Color(${activeTheme.primaryHex});
  static const bg = Color(${activeTheme.bgHex});
  static const accent = Color(${activeTheme.accentHex});
}`}
                </pre>
              </div>

              {/* Floating Bottom Nav Snippet */}
              <div className="bg-slate-50 rounded-2xl p-4 border border-slate-200/60 relative">
                <div className="flex justify-between items-center mb-2">
                  <span className="text-[10px] font-mono text-slate-400 font-bold">FloatingGlassNavBar Snippet</span>
                  <button 
                    onClick={() => copyWidgetCode(`// bottom_nav_bar.dart
Widget buildFloatingGlassNavBar(BuildContext context) {
  return Container(
    height: 72,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 15,
        ),
      ],
    ),
  );
}`, "nav")}
                    className="text-slate-500 hover:text-slate-800 p-1.5 rounded hover:bg-slate-200/50 cursor-pointer transition-all"
                  >
                    {copiedCodeCode === "nav" ? <Check className="w-3.5 h-3.5 text-indigo-600 animate-pulse" /> : <Copy className="w-3.5 h-3.5" />}
                  </button>
                </div>
                <pre className="text-[10px] font-mono text-slate-600 overflow-x-auto whitespace-pre leading-normal">
                  {`// bottom_nav_bar.dart
Widget buildFloatingNavBar() {
  return Container(
    borderRadius: BorderRadius.circular(30),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      backdropFilter: ImageFilter.blur(),
    ),
  );
}`}
                </pre>
              </div>

            </div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 flex-1 flex flex-col justify-between min-h-[220px]">
            <div>
              <h4 className="font-bold text-slate-800 mb-2 flex items-center gap-1.5 text-xs">
                <FileText className="w-4 h-4 text-indigo-600" />
                <span>Physical Blueprint Generated</span>
              </h4>
              <p className="text-xs text-slate-500 leading-relaxed mb-3">
                This app is accompanied by a highly detailed, professional markdown blueprint named <strong className="text-slate-800 font-bold">`/design.md`</strong> inside your workspace root.
              </p>
              <p className="text-xs text-slate-500 leading-relaxed mb-4">
                Verify its absolute rules on styling, fonts, shadow factors, and dual English/Arabic directionality layouts.
              </p>
            </div>
            
            <a 
              href="https://ais-dev-ktzk3mlq5q6kuxg2zkveng-357805963840.europe-west2.run.app/design.md"
              target="_blank" 
              referrerPolicy="no-referrer"
              className="bg-slate-50 hover:bg-slate-100 text-indigo-600 border border-slate-200 px-4 py-3 rounded-xl font-bold text-xs flex items-center justify-center gap-2 transition-all text-center select-none cursor-pointer shadow-sm"
            >
              <span>Verify design.md online</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </a>
          </div>

        </div>

      </main>

      {/* FOOTER SECTION: Dynamic Cursor Prompt Workspace Container */}
      <section id="prompt-section" className="bg-slate-900 border-t border-slate-800 text-white mt-12 py-12 px-6">
        <div className="max-w-7xl mx-auto space-y-6">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
            <div className="space-y-1">
              <h2 className="text-xl font-black text-white flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-indigo-400" />
                <span>Targeted Cursor Redesign AI Prompt</span>
              </h2>
              <p className="text-sm text-slate-400">
                Copy this engineered prompt and paste it directly into Cursor (or any Chat window, matching your app layout) to trigger a step-by-step file revamp.
              </p>
            </div>
            
            <button
              onClick={copyPromptToClipboard}
              className={`px-5 py-3 rounded-xl text-xs font-bold flex items-center gap-2 cursor-pointer transition-all shrink-0 ${
                copiedPrompt 
                  ? "bg-emerald-600 text-white scale-102 shadow-lg shadow-emerald-950/20" 
                  : "bg-indigo-600 text-white hover:bg-indigo-500"
              }`}
            >
              {copiedPrompt ? (
                <>
                  <Check className="w-4 h-4 font-bold" />
                  <span>Prompt Copied Successfully!</span>
                </>
              ) : (
                <>
                  <Copy className="w-4 h-4" />
                  <span>Copy Re-design Prompt</span>
                </>
              )}
            </button>
          </div>

          {/* Prompt Terminal Viewport */}
          <div className="bg-slate-950 rounded-2xl border border-slate-800 p-5 font-mono text-slate-300 text-xs leading-relaxed max-h-[350px] overflow-y-auto scrollbar-thin shadow-inner relative group">
            <div className="absolute right-4 top-4 opacity-0 group-hover:opacity-100 transition-opacity">
              <button 
                onClick={copyPromptToClipboard}
                className="bg-slate-950 border border-slate-800 text-slate-400 hover:text-white p-2 rounded-xl"
              >
                <Copy className="w-4 h-4" />
              </button>
            </div>
            
            {/* The Text prompt blocks */}
            <span className="text-slate-500 font-bold block mb-4">// =================== RE-DESIGN INSTRUCTIONS FOR CURSOR ===================</span>
            <p className="whitespace-pre-wrap">{generatedCursorPrompt}</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-4 text-xs text-slate-400 leading-normal">
            <div className="bg-slate-800/40 p-4 rounded-xl border border-slate-800/60">
              <strong className="text-white block font-semibold mb-1">💡 How to use with Cursor:</strong>
              Open your project in Cursor, press <kbd className="bg-slate-700 text-white px-1 py-0.5 rounded text-[10px] font-sans font-bold">Ctrl+K</kbd> or open the side Chat, paste this prompt, and watch the layout refine itself step-by-step.
            </div>
            <div className="bg-slate-800/40 p-4 rounded-xl border border-slate-800/60">
              <strong className="text-white block font-semibold mb-1">🛠️ Font Installation Note:</strong>
              Add the <code className="text-indigo-400">Cairo</code> or <code className="text-indigo-400">Readex Pro</code> fonts package in <code className="text-slate-300 font-mono">pubspec.yaml</code> so Arabic letterforms align and format correctly.
            </div>
            <div className="bg-slate-800/40 p-4 rounded-xl border border-slate-800/60">
              <strong className="text-white block font-semibold mb-1">🚀 Clean Architecture:</strong>
              Maintain modularity inside your Lib folders. Separate your style constants, helper widgets, and individual screens cleanly.
            </div>
          </div>

        </div>
      </section>

      {/* Flat Mini Copyright line */}
      <footer className="bg-slate-950 text-slate-500 text-center py-6 text-xs border-t border-slate-900 select-none">
        <p>© 2026 Google AI Studio Redesign Suite. Crafted with premium design tokens.</p>
      </footer>
    </div>
  );
}
