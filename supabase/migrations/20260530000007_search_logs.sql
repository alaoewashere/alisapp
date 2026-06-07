-- Search analytics (insert-only)
CREATE TABLE IF NOT EXISTS public.search_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  query TEXT NOT NULL,
  results_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS search_logs_created_at_idx
  ON public.search_logs (created_at DESC);

ALTER TABLE public.search_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can insert search logs"
  ON public.search_logs FOR INSERT
  WITH CHECK (true);
