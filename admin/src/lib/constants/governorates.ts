// 18 Iraqi governorates — mirrors the Flutter app + governorates seed table.
export interface Governorate {
  slug: string;
  nameAr: string;
  nameEn: string;
}

export const governorates: Governorate[] = [
  { slug: "baghdad", nameAr: "بغداد", nameEn: "Baghdad" },
  { slug: "basra", nameAr: "البصرة", nameEn: "Basra" },
  { slug: "nineveh", nameAr: "نينوى", nameEn: "Nineveh" },
  { slug: "erbil", nameAr: "أربيل", nameEn: "Erbil" },
  { slug: "sulaymaniyah", nameAr: "السليمانية", nameEn: "Sulaymaniyah" },
  { slug: "duhok", nameAr: "دهوك", nameEn: "Duhok" },
  { slug: "kirkuk", nameAr: "كركوك", nameEn: "Kirkuk" },
  { slug: "anbar", nameAr: "الأنبار", nameEn: "Anbar" },
  { slug: "babil", nameAr: "بابل", nameEn: "Babil" },
  { slug: "diyala", nameAr: "ديالى", nameEn: "Diyala" },
  { slug: "karbala", nameAr: "كربلاء", nameEn: "Karbala" },
  { slug: "najaf", nameAr: "النجف", nameEn: "Najaf" },
  { slug: "wasit", nameAr: "واسط", nameEn: "Wasit" },
  { slug: "maysan", nameAr: "ميسان", nameEn: "Maysan" },
  { slug: "dhi_qar", nameAr: "ذي قار", nameEn: "Dhi Qar" },
  { slug: "muthanna", nameAr: "المثنى", nameEn: "Muthanna" },
  { slug: "qadisiyyah", nameAr: "القادسية", nameEn: "Qadisiyyah" },
  { slug: "saladin", nameAr: "صلاح الدين", nameEn: "Saladin" },
];

const bySlug = new Map(governorates.map((g) => [g.slug, g]));

export function governorateNameAr(slug: string | null | undefined): string {
  if (!slug) return "—";
  return bySlug.get(slug)?.nameAr ?? slug;
}
