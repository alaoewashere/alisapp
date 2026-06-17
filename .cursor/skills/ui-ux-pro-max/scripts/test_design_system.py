#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Tests for Sello design system generator (Thmanyah fonts, no emojis)."""

import re
import unittest
from pathlib import Path

from design_system import (
    DesignSystemGenerator,
    _build_sello_typography,
    _thmanyah_font_face,
    format_markdown,
    format_master_md,
)
from search import format_output


FORBIDDEN_EMOJIS = ["✅", "📄", "📖", "❌", "⚠️"]


class TestSelloTypography(unittest.TestCase):
    def test_build_sello_typography_families(self):
        typo = _build_sello_typography()
        self.assertEqual(typo["heading"], "Thmanyah Serif Display")
        self.assertEqual(typo["body"], "Thmanyah Sans")
        self.assertEqual(typo["longform"], "Thmanyah Serif Text")
        self.assertEqual(typo["font_dir"], "assets/fonts")
        self.assertIn("font_face_css", typo)

    def test_thmanyah_font_face_paths(self):
        css = _thmanyah_font_face()
        self.assertIn("@font-face", css)
        self.assertIn("assets/fonts/thmanyahsans/thmanyahsans-Regular.otf", css)
        self.assertIn("assets/fonts/thmanyahserifdisplay/thmanyahserifdisplay-Bold.otf", css)
        self.assertIn("assets/fonts/thmanyahseriftext/thmanyahseriftext-Medium.otf", css)
        self.assertNotIn("fonts.googleapis.com", css)

    def test_generate_returns_thmanyah_typography(self):
        generator = DesignSystemGenerator()
        result = generator.generate("wellness spa landing", "Sello")
        typo = result["typography"]
        self.assertEqual(typo["heading"], "Thmanyah Serif Display")
        self.assertEqual(typo["body"], "Thmanyah Sans")
        self.assertEqual(typo["longform"], "Thmanyah Serif Text")
        self.assertIn("font_face_css", typo)
        self.assertNotIn("google_fonts_url", typo)
        self.assertNotIn("css_import", typo)


class TestSelloFormatters(unittest.TestCase):
    def setUp(self):
        self.generator = DesignSystemGenerator()
        self.design_system = self.generator.generate("wellness spa landing", "Sello")

    def _assert_no_forbidden_emojis(self, text: str):
        for emoji in FORBIDDEN_EMOJIS:
            self.assertNotIn(emoji, text, f"Found forbidden emoji: {emoji}")

    def test_format_markdown_thmanyah_and_font_face(self):
        md = format_markdown(self.design_system)
        self.assertIn("Thmanyah Serif Display", md)
        self.assertIn("Thmanyah Sans", md)
        self.assertIn("Thmanyah Serif Text", md)
        self.assertIn("@font-face", md)
        self.assertIn("assets/fonts/", md)
        self.assertNotIn("fonts.googleapis.com", md)
        self.assertNotIn("Google Fonts", md)
        self._assert_no_forbidden_emojis(md)

    def test_format_master_md_thmanyah_and_text_icons(self):
        md = format_master_md(self.design_system)
        self.assertIn("@font-face", md)
        self.assertIn("assets/fonts/", md)
        self.assertNotIn("fonts.googleapis.com", md)
        self.assertIn("[X]", md)
        self._assert_no_forbidden_emojis(md)


class TestSelloSearchBranding(unittest.TestCase):
    def test_format_output_headers_use_sello(self):
        result = {
            "domain": "style",
            "query": "minimal",
            "file": "styles.csv",
            "count": 1,
            "results": [{"Style Category": "Minimalism"}],
        }
        output = format_output(result)
        self.assertIn("## Sello Search Results", output)
        self.assertNotIn("UI Pro Max", output)

    def test_search_py_source_has_sello_headers(self):
        search_path = Path(__file__).parent / "search.py"
        content = search_path.read_text(encoding="utf-8")
        self.assertIn("## Sello Search Results", content)
        self.assertIn("## Sello Stack Guidelines", content)
        self.assertIn("[OK]", content)
        self.assertIn("[FILE]", content)
        self.assertIn("[GUIDE]", content)
        for emoji in FORBIDDEN_EMOJIS:
            self.assertNotIn(emoji, content)


if __name__ == "__main__":
    unittest.main()
