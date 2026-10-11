# Keep CLI builds consistent with LaTeX Workshop
$out_dir = 'build';

# Build standalone figure sources whose PDF is still missing.
# Skip during latexmk -c / -C so cleanup does not compile plots.
unless ($cleanup_mode) {
  system('bash', 'scripts/build-tikz-figures.sh') == 0
    or die "TikZ figure build failed\n";
}
