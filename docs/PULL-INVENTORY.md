# Pull inventory

File-level inventory of upstream sources **before** packedbox selective pull.
Source repos remain authoritative and are **not deleted** — see [README](../README.md#source-repos).

---

## shellyxz.sh

| Field | Value |
|-------|-------|
| Repository | [p10ns11y/shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) |
| Branch | `master` |
| Blob count | 180 |
| Captured | 2026-09-07 09:39 UTC via `gh api …/git/trees/master?recursive=1` |

### Top-level summary

| Path | Files |
|------|------:|
| `bin/` | 37 |
| `plugins/` | 33 |
| `.agents/` | 31 |
| `templates/` | 17 |
| `arch-design/` | 11 |
| `environments/` | 9 |
| `core/` | 8 |
| `planned-features/` | 8 |
| `.cursor/` | 6 |
| `local/` | 5 |
| `.envrc.example/` | 1 |
| `.gitignore/` | 1 |
| `.path.contract.example/` | 1 |
| `PLUGIN.md/` | 1 |
| `README.md/` | 1 |
| `aliases.sh/` | 1 |
| `env.sh/` | 1 |
| `environment.example/` | 1 |
| `functions.sh/` | 1 |
| `git.ex.config/` | 1 |
| `lib.sh/` | 1 |
| `motivation.md/` | 1 |
| `personal.sh/` | 1 |
| `starship.ex.toml/` | 1 |
| `yazi.ex.toml/` | 1 |

### Full file listing

<details>
<summary>180 files (click to expand)</summary>

```
.agents/README.md
.agents/ontology/GRAPH.md
.agents/ontology/INDEX.md
.agents/ontology/fusion-state.json
.agents/ontology/ontology.schema.json
.agents/ontology/shell-kernel.extracted.yaml
.agents/ontology/shell-kernel.graph.yaml
.agents/skills/README.md
.agents/skills/shell-kernel-ontology/SKILL.md
.agents/skills/stellar-roadmap/SKILL.md
.agents/skills/stellar-roadmap/assets/cursorrules-template.md
.agents/skills/stellar-roadmap/examples/README.md
.agents/skills/stellar-roadmap/examples/eve-agent.md
.agents/skills/stellar-roadmap/examples/shell-kernel.md
.agents/skills/stellar-roadmap/references/companion-skills.md
.agents/skills/stellar-roadmap/references/document-template.md
.agents/skills/stellar-roadmap/references/external-sources.md
.agents/skills/verification-cockpit/SKILL.md
.agents/skills/verification-cockpit/reference.md
.agents/skills/verification-cockpit/templates/README.md
.agents/skills/verification-cockpit/templates/cockpit.yaml
.agents/skills/verification-cockpit/templates/manifest.yaml
.agents/skills/verification-cockpit/templates/tests.yaml
.agents/skills/verification-cockpit/templates/tmux-layout.sh
.agents/skills/verification-cockpit/templates/tmux-theme.conf
.agents/verification/README.md
.agents/verification/cockpit.yaml
.agents/verification/manifest.yaml
.agents/verification/tests.yaml
.agents/verification/tmux-layout.sh
.agents/verification/tmux-theme.conf
.cursor/agents/cockpit-next.md
.cursor/plans/verification_workflow_cockpit_2614c945.plan.md
.cursor/rules/ontology-router.mdc
.cursor/rules/shell-readability.mdc
.cursor/skills
.cursor/verify
.envrc.example
.gitignore
.path.contract.example
PLUGIN.md
README.md
aliases.sh
arch-design/README.md
arch-design/SHELL-env-var-behavior.md
arch-design/VERIFICATION.md
arch-design/architecture.md
arch-design/coming-next.md
arch-design/human-in-the-loop-workflow.md
arch-design/overlays/shell-kernel-decision-hooks.md
arch-design/plans/shell-kernel-ontology.md
arch-design/shell-script-readability.md
arch-design/shell.md
arch-design/test-of-travelled-time-from-future.md
bin/README.md
bin/agent-build-layout.sh
bin/agent-test-layout.sh
bin/agent-verify-layout.sh
bin/capture-shell-init.sh
bin/check-ontology.sh
bin/check-shell-watch.sh
bin/check-shell.sh
bin/check-template-sync.sh
bin/cockpit-mcp.sh
bin/extract-ontology-facts.sh
bin/fzf-preview.sh
bin/lib/migrate-common.sh
bin/migrate.sh
bin/path-contract-project.sh
bin/project-test-watch.sh
bin/recover-shell.sh
bin/render-ontology-graph.sh
bin/run-project-tests.sh
bin/scaffold-environment.sh
bin/sync-tmux-verify.sh
bin/tasks/backup.sh
bin/tasks/git-commit.sh
bin/tasks/install-modules.sh
bin/tasks/install-rc.sh
bin/tasks/install-tools.sh
bin/tasks/scaffold.sh
bin/test/capture-shell-init.test.sh
bin/test/parse-project-tests.test.sh
bin/test/path-contract.test.sh
bin/test/strict-path.test.sh
bin/test/verify-workflow-root.test.sh
bin/tmux-cycle-layout.sh
bin/tmux-keymap-menu.sh
bin/tmux-mode-sync.sh
bin/verify-pane-launch.sh
bin/verify-workflow-root.sh
core/aliases.sh
core/env.sh
core/functions.sh
core/lib.sh
core/path-resolve.sh
core/path.contract
core/path.sh
core/tool.contract
env.sh
environment.example
environments/README.md
environments/generic/bash.sh
environments/generic/env.sh
environments/generic/fish.sh
environments/generic/zsh.sh
environments/omarchy/bash.sh
environments/omarchy/env.sh
environments/omarchy/fish.sh
environments/omarchy/zsh.sh
functions.sh
git.ex.config
lib.sh
local/omarchy.sh.example
local/overwrite.sh.example
local/path.contract
local/path.contract.example
local/personal.sh
motivation.md
personal.sh
planned-features/README.md
planned-features/done/README.md
planned-features/done/ontology-viz-hoda-pr12.md
planned-features/done/path-contract-v2-pr6.md
planned-features/done/sn-o0-sn4a-pr11.md
planned-features/done/sn-o1-ontology-verification.md
planned-features/done/sn-ts-sn8-pr9.md
planned-features/done/sprint-jun-2026-pr8.md
plugins/README.md
plugins/verification/README.md
plugins/verification/bin/agent-build-layout.sh
plugins/verification/bin/agent-test-layout.sh
plugins/verification/bin/agent-verify-layout.sh
plugins/verification/bin/cockpit-mcp.sh
plugins/verification/bin/project-test-watch.sh
plugins/verification/bin/run-project-tests.sh
plugins/verification/bin/sync-tmux-verify.sh
plugins/verification/bin/tmux-cycle-layout.sh
plugins/verification/bin/tmux-keymap-menu.sh
plugins/verification/bin/tmux-mode-sync.sh
plugins/verification/bin/verify-pane-launch.sh
plugins/verification/conf/tmux.status-mode.conf.ex
plugins/verification/conf/tmux.verify-soc-theme.conf.ex
plugins/verification/conf/tmux.verify.conf.ex
plugins/verification/data/tmux-keymaps.tsv
plugins/verification/docs/cockpit-build.jpg
plugins/verification/docs/cockpit-guard-diff.jpg
plugins/verification/docs/cockpit-test.jpg
plugins/verification/docs/cockpit-tmux-ok-docs.jpg
plugins/verification/docs/cockpit-verify.jpg
plugins/verification/lib/discover-tests.sh
plugins/verification/lib/parse-project-tests-discover.sh
plugins/verification/lib/parse-project-tests-run.sh
plugins/verification/lib/parse-project-tests.py
plugins/verification/lib/parse-project-tests.sh
plugins/verification/lib/project-build.sh
plugins/verification/lib/project-tests.sh
plugins/verification/lib/test-allowlist.sh
plugins/verification/lib/tmux-status-mode.sh
plugins/verification/lib/verify-launch.sh
plugins/verification/lib/verify-layout.sh
starship.ex.toml
templates/bashrc
templates/core/aliases.sh
templates/core/env.sh
templates/core/functions.sh
templates/core/lib.sh
templates/core/path-resolve.sh
templates/core/path.contract
templates/core/path.sh
templates/core/tool.contract
templates/environments/omarchy/env.sh
templates/fish.config.fish
templates/login/bash_profile
templates/login/profile
templates/login/zprofile
templates/login/zshenv
templates/tool-init.manifest
templates/zshrc
yazi.ex.toml
```

</details>

## arch-machine

| Field | Value |
|-------|-------|
| Repository | [p10ns11y/arch-machine](https://github.com/p10ns11y/arch-machine) |
| Branch | `sentinel` |
| Blob count | 448 |
| Captured | 2026-09-07 09:39 UTC via `gh api …/git/trees/sentinel?recursive=1` |

### Top-level summary

| Path | Files |
|------|------:|
| `modules/` | 184 |
| `.agents/` | 71 |
| `tools/` | 50 |
| `.grok/` | 32 |
| `.cursor/` | 18 |
| `docs/` | 17 |
| `maintenance/` | 14 |
| `lib/` | 10 |
| `.github/` | 7 |
| `config/` | 7 |
| `arch-design/` | 5 |
| `policies/` | 4 |
| `bin/` | 2 |
| `devplays/` | 2 |
| `.gitignore/` | 1 |
| `.markdownlint.json/` | 1 |
| `.shellcheckrc/` | 1 |
| `.yamllint.yml/` | 1 |
| `AGENTS.md/` | 1 |
| `AUTHORS-MOTTO.md/` | 1 |
| `FUNREADME.md/` | 1 |
| `LICENSE/` | 1 |
| `Makefile/` | 1 |
| `PROGRESS.md/` | 1 |
| `README.md/` | 1 |
| `SAFETY.md/` | 1 |
| `STATE.md/` | 1 |
| `VAULT-GUIDE.md/` | 1 |
| `archy.jpg/` | 1 |
| `install.sh/` | 1 |
| `logs/` | 1 |
| `migrate.sh/` | 1 |
| `sbom.cdx.json/` | 1 |
| `scripts/` | 1 |
| `sentinels-ultimate-masters.jpg/` | 1 |
| `skills-lock.json/` | 1 |
| `tinfoil-name-explained.md/` | 1 |
| `tinfoil.jpg/` | 1 |
| `vector.toml/` | 1 |

### Full file listing

<details>
<summary>448 files (click to expand)</summary>

```
.agents/fusion-state.json
.agents/ontology/GRAPH.md
.agents/ontology/INDEX.md
.agents/ontology/arch-machine.graph.yaml
.agents/overlays/arch-machine-ai-optimization.md
.agents/overlays/arch-machine-decision-hooks.md
.agents/overlays/arch-machine-fusion-sage.md
.agents/overlays/arch-machine-master-planner.md
.agents/overlays/arch-machine-stellar-roadmap.md
.agents/rules/ai-optimization.mdc
.agents/rules/fusion-sage.mdc
.agents/rules/higher-order-decision-architect.mdc
.agents/rules/master-planner.mdc
.agents/rules/stellar-roadmap.mdc
.agents/skills/agent-orchestrator/SKILL.md
.agents/skills/agent-orchestrator/templates/task-brief.md
.agents/skills/ai-optimization/SKILL.md
.agents/skills/ai-optimization/assets/cursorrules-template.md
.agents/skills/ai-optimization/references/python-optimizer.md
.agents/skills/ai-optimization/references/rust-optimizer.md
.agents/skills/ai-optimization/references/typescript-optimizer.md
.agents/skills/ai-optimization/scripts/context-sage.py
.agents/skills/ai-optimization/tested.md
.agents/skills/eagle-satellite-elomaxz/SKILL.md
.agents/skills/eagle-satellite-elomaxz/references/machine-graph.md
.agents/skills/fusion-sage/README.md
.agents/skills/fusion-sage/SKILL.md
.agents/skills/fusion-sage/fusion-playbooks.md
.agents/skills/fusion-sage/fusion-state.json
.agents/skills/fusion-sage/fusion-state.schema.json
.agents/skills/fusion-sage/fusion-surplus-examples.md
.agents/skills/git-worktrees/SKILL.md
.agents/skills/git-worktrees/scripts/agent-worktree-clean.sh
.agents/skills/git-worktrees/scripts/agent-worktree-list.sh
.agents/skills/git-worktrees/scripts/agent-worktree-merge.sh
.agents/skills/git-worktrees/scripts/agent-worktree-remove.sh
.agents/skills/higher-order-decision-architect/SKILL.md
.agents/skills/looper/README.md
.agents/skills/looper/SKILL.md
.agents/skills/looper/references/loop-card.md
.agents/skills/looper/scripts/validate-skill.mjs
.agents/skills/master-planner/SKILL.md
.agents/skills/master-planner/examples/arch-machine-pack.md
.agents/skills/master-planner/references/ontology-template.md
.agents/skills/master-planner/references/orwell-tweak.md
.agents/skills/master-planner/scripts/pull-skills.sh
.agents/skills/master-planner/scripts/verify-pack.sh
.agents/skills/session-unit-order/SKILL.md
.agents/skills/session-unit-order/references/incident-uwsm-graphical-session.md
.agents/skills/session-unit-order/scripts/audit-session-units.sh
.agents/skills/stellar-roadmap/SKILL.md
.agents/skills/stellar-roadmap/assets/cursorrules-template.md
.agents/skills/stellar-roadmap/examples/README.md
.agents/skills/stellar-roadmap/examples/eve-agent.md
.agents/skills/stellar-roadmap/examples/shell-kernel.md
.agents/skills/stellar-roadmap/references/companion-skills.md
.agents/skills/stellar-roadmap/references/document-template.md
.agents/skills/stellar-roadmap/references/external-sources.md
.agents/skills/verification-cockpit/SKILL.md
.agents/skills/verification-cockpit/reference.md
.agents/skills/verification-cockpit/templates/README.md
.agents/skills/verification-cockpit/templates/manifest.yaml
.agents/skills/verification-cockpit/templates/tests.yaml
.agents/skills/verification-cockpit/templates/tmux-layout.sh
.agents/skills/verification-cockpit/templates/tmux-theme.conf
.agents/verification/README.md
.agents/verification/cockpit.yaml
.agents/verification/manifest.yaml
.agents/verification/tests.yaml
.agents/verification/tmux-layout.sh
.agents/verification/tmux-theme.conf
.cursor/agents/sentinel-git-investigator.md
.cursor/rules/ai-optimization.mdc
.cursor/rules/fusion-sage.mdc
.cursor/rules/higher-order-decision-architect.mdc
.cursor/rules/master-planner.mdc
.cursor/rules/stellar-roadmap.mdc
.cursor/skills/agent-orchestrator
.cursor/skills/ai-optimization
.cursor/skills/eagle-satellite-elomaxz
.cursor/skills/fusion-sage
.cursor/skills/git-worktrees
.cursor/skills/higher-order-decision-architect
.cursor/skills/looper
.cursor/skills/master-planner
.cursor/skills/session-unit-order
.cursor/skills/stellar-roadmap
.cursor/skills/verification-cockpit
.cursor/verify
.github/CODEOWNERS
.github/ISSUE_TEMPLATE/bug_report.md
.github/ISSUE_TEMPLATE/feature_request.md
.github/PULL_REQUEST_TEMPLATE.md
.github/SECURITY.md
.github/dependabot.yml
.github/workflows/ci.yml
.gitignore
.grok/hardware-acceleration/amd-internal-npu-igpu-cpu-optimization.md
.grok/hardware-acceleration/intel-internal-npu-igpu-cpu-optimization.md
.grok/hardware-acceleration/nvidia-extrenal-gpu.md
.grok/hardware-acceleration/optimization-for-local-agents.md
.grok/hardware-acceleration/quantization.md
.grok/hardware-acceleration/workflow.md
.grok/ideas/elomaxz-integration/CMake_FetchContent_Guide.md
.grok/ideas/elomaxz-integration/C_LIBRARY_IMPORTS.md
.grok/ideas/elomaxz-integration/INTEGRATION_PLAN_arch-machine.md
.grok/ideas/elomaxz-integration/INTEGRATION_PLAN_arch-machine_cmake.md
.grok/overnight-autonomous/arch-machine-overhaul/CONTEXT.md
.grok/overnight-autonomous/arch-machine-overhaul/EVIDENCE/README.md
.grok/overnight-autonomous/arch-machine-overhaul/INIT_PLAN.md
.grok/overnight-autonomous/arch-machine-overhaul/PROGRESS.md
.grok/overnight-autonomous/arch-machine-overhaul/README.md
.grok/overnight-autonomous/arch-machine-overhaul/STATE.md
.grok/rules/ai-optimization.mdc
.grok/rules/fusion-sage.mdc
.grok/rules/higher-order-decision-architect.mdc
.grok/rules/master-planner.mdc
.grok/rules/stellar-roadmap.mdc
.grok/skills/agent-orchestrator
.grok/skills/ai-optimization
.grok/skills/eagle-satellite-elomaxz
.grok/skills/fusion-sage
.grok/skills/git-worktrees
.grok/skills/higher-order-decision-architect
.grok/skills/looper
.grok/skills/master-planner
.grok/skills/session-unit-order
.grok/skills/stellar-roadmap
.grok/skills/verification-cockpit
.markdownlint.json
.shellcheckrc
.yamllint.yml
AGENTS.md
AUTHORS-MOTTO.md
FUNREADME.md
LICENSE
Makefile
PROGRESS.md
README.md
SAFETY.md
STATE.md
VAULT-GUIDE.md
arch-design/coming-next-keeper.md
arch-design/coming-next.md
arch-design/evolutions/2026-07-22.md
arch-design/keeper.md
arch-design/soft-obsolete-candidates.md
archy.jpg
bin/groxy
bin/tinfoil.go
config/baselines/omarchy.yaml
config/groxy/allowlist.conf
config/groxy/allowlist.conf.example
config/profiles/minimal.yaml
config/profiles/ml-dev.yaml
config/profiles/security-dev.yaml
config/tools.yaml
devplays/README.md
devplays/cilium-teragon-clusters.sh
docs/BACKUP.md
docs/CONTRIBUTING.md
docs/DEVELOPMENT.md
docs/INDEX.md
docs/INSTALLATION.md
docs/LEGACY.md
docs/MAINTENANCE.md
docs/MODULES.md
docs/SECRETS-EVERYDAY.md
docs/TROUBLESHOOTING.md
docs/archy.md
docs/eye-comfort.md
docs/groxy.md
docs/omarchy-commands.md
docs/omarchy.md
docs/storyline.md
docs/test-secrets-everyday.sh
install.sh
lib/evidence.sh
lib/installer.sh
lib/logger.sh
lib/tui.sh
lib/tui/messages.sh
lib/tui/model.sh
lib/tui/update.sh
lib/tui/view.sh
lib/validator.sh
lib/validator_advanced.sh
logs/.gitkeep
maintenance/apply-updates.sh
maintenance/backup.sh
maintenance/catalog.sh
maintenance/check-updates.sh
maintenance/cron-setup.sh
maintenance/extract-evidence.sh
maintenance/inventory.sh
maintenance/notify.sh
maintenance/omarchy-status.sh
maintenance/package-actuate.sh
maintenance/securetools.csv
maintenance/security-audit.sh
maintenance/systemd-setup.sh
maintenance/weekly-check.sh
migrate.sh
modules/development/install.sh
modules/ml_ai/install.sh
modules/productivity/eye-comfort/DESIGN-TN.md
modules/productivity/eye-comfort/DESIGN.md
modules/productivity/eye-comfort/PRODUCT-TN.md
modules/productivity/eye-comfort/PRODUCT.md
modules/productivity/eye-comfort/README.md
modules/productivity/eye-comfort/bin/eye-comfort-theme
modules/productivity/eye-comfort/docs/DESIGN-TN.md
modules/productivity/eye-comfort/docs/DESIGN.md
modules/productivity/eye-comfort/docs/HOST-EDITS.md
modules/productivity/eye-comfort/docs/PALETTE.md
modules/productivity/eye-comfort/docs/PRODUCT-IN.md
modules/productivity/eye-comfort/docs/PRODUCT-SE.md
modules/productivity/eye-comfort/docs/PRODUCT-TN.md
modules/productivity/eye-comfort/docs/PRODUCT-US.md
modules/productivity/eye-comfort/docs/PRODUCT.md
modules/productivity/eye-comfort/docs/REGRESSION-UWSM-SESSION.md
modules/productivity/eye-comfort/hooks/theme-set.d/90-reload-nvim-tmux.sh
modules/productivity/eye-comfort/hooks/theme-set.d/91-delta-bat.sh
modules/productivity/eye-comfort/install.sh
modules/productivity/eye-comfort/lib/generate_packages.py
modules/productivity/eye-comfort/lib/oklch.py
modules/productivity/eye-comfort/lib/palette.py
modules/productivity/eye-comfort/lib/render.py
modules/productivity/eye-comfort/lib/schedule.py
modules/productivity/eye-comfort/lib/tamil_palette.py
modules/productivity/eye-comfort/lib/tamil_schedule.py
modules/productivity/eye-comfort/lib/test_schedule.py
modules/productivity/eye-comfort/lib/test_tamil_schedule.py
modules/productivity/eye-comfort/lib/test_timer_mutex.py
modules/productivity/eye-comfort/lib/test_waybar_css.py
modules/productivity/eye-comfort/lib/waybar_status.py
modules/productivity/eye-comfort/nvim/omarchy-theme-hotreload.lua
modules/productivity/eye-comfort/snippets/ghostty.fragment.conf
modules/productivity/eye-comfort/themes/eye-comfort-dark/backgrounds/0-signature-lantern.jpg
modules/productivity/eye-comfort/themes/eye-comfort-dark/backgrounds/1-journals-tea.jpg
modules/productivity/eye-comfort/themes/eye-comfort-dark/backgrounds/2-sage-amber-ribbons.jpg
modules/productivity/eye-comfort/themes/eye-comfort-dark/backgrounds/3-mist-valley-ink.jpg
modules/productivity/eye-comfort/themes/eye-comfort-dark/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-dark/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-dark/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-dark/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-dark/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-dawn/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-dawn/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-dawn/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-dawn/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-dawn/light.mode
modules/productivity/eye-comfort/themes/eye-comfort-dawn/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-dusk/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-dusk/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-dusk/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-dusk/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-dusk/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-light/backgrounds/1-parchment-dunes.jpg
modules/productivity/eye-comfort/themes/eye-comfort-light/backgrounds/2-cream-botanical.jpg
modules/productivity/eye-comfort/themes/eye-comfort-light/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-light/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-light/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-light/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-light/light.mode
modules/productivity/eye-comfort/themes/eye-comfort-light/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-default.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-erpaadu-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-erpaadu-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-kaalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-kaalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-maalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-maalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-nanpagal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-nanpagal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-vidiyal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-vidiyal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-yaamam-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/backgrounds/kurinji-yaamam-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-tn-kurinji/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-default.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-erpaadu-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-erpaadu-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-kaalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-kaalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-maalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-maalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-nanpagal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-nanpagal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-vidiyal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-vidiyal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-yaamam-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/backgrounds/marutham-yaamam-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-tn-marutham/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-default.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-erpaadu-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-erpaadu-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-kaalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-kaalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-maalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-maalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-nanpagal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-nanpagal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-vidiyal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-vidiyal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-yaamam-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/backgrounds/mullai-yaamam-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-tn-mullai/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-default.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-erpaadu-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-erpaadu-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-kaalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-kaalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-maalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-maalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-nanpagal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-nanpagal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-vidiyal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-vidiyal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-yaamam-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/backgrounds/neythal-yaamam-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-tn-neythal/neovim.lua
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/README.md
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-default.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-erpaadu-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-erpaadu-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-kaalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-kaalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-maalai-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-maalai-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-nanpagal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-nanpagal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-vidiyal-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-vidiyal-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-yaamam-a.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/backgrounds/palai-yaamam-b.jpg
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/colors.toml
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/ghostty.conf
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/icons.theme
modules/productivity/eye-comfort/themes/eye-comfort-tn-palai/neovim.lua
modules/productivity/eye-comfort/tokens/phases.css
modules/productivity/eye-comfort/tokens/roles.json
modules/productivity/eye-comfort/units/eye-comfort-theme.service
modules/productivity/eye-comfort/units/eye-comfort-theme.timer
modules/productivity/eye-comfort/units/eye-comfort-tn.service
modules/productivity/eye-comfort/units/eye-comfort-tn.timer
modules/productivity/eye-comfort/waybar/eye-comfort.css
modules/productivity/eye-comfort/waybar/module.jsonc
modules/productivity/eye-comfort/waybar/tn-status.sh
modules/productivity/eye-comfort/wrappers/omarchy-restart-waybar
modules/productivity/eye-comfort/wrappers/uwsm-app
modules/productivity/eye-comfort/yazi/flavors/eye-comfort-dark.yazi/flavor.toml
modules/productivity/eye-comfort/yazi/flavors/eye-comfort-light.yazi/flavor.toml
modules/productivity/eye-comfort/yazi/theme.toml
modules/productivity/install.sh
modules/productivity/personal-tweaks/HOST-EDITS.md
modules/productivity/personal-tweaks/README.md
modules/productivity/personal-tweaks/desktop/kanithanj.ai.desktop
modules/productivity/personal-tweaks/hooks/92-heading-chip.sh
modules/productivity/personal-tweaks/install.sh
modules/productivity/personal-tweaks/lib/apply-waybar.sh
modules/productivity/personal-tweaks/lib/backup-waybar.sh
modules/productivity/personal-tweaks/lib/patch_waybar.py
modules/productivity/personal-tweaks/lib/test_patch_waybar.py
modules/productivity/personal-tweaks/units/mission-map-graph.service
modules/productivity/personal-tweaks/units/mission-map-graph.timer
modules/productivity/personal-tweaks/waybar/mission-map.css
modules/productivity/personal-tweaks/waybar/module.jsonc
modules/security/install.sh
modules/security/keeper/README.md
modules/system/install.sh
policies/orwell-simple-language-rules.md
policies/package-refuse-list.txt
policies/security-remediation-orwell.md
policies/security-remediation.md
sbom.cdx.json
scripts/profile-validation-harness.sh
sentinels-ultimate-masters.jpg
skills-lock.json
tinfoil-name-explained.md
tinfoil.jpg
tools/archy/Cargo.lock
tools/archy/Cargo.toml
tools/archy/README.md
tools/archy/src/actions.rs
tools/archy/src/app.rs
tools/archy/src/cmd.rs
tools/archy/src/eagle.rs
tools/archy/src/fsm.rs
tools/archy/src/grok_launch.rs
tools/archy/src/jobs.rs
tools/archy/src/main.rs
tools/archy/src/msg.rs
tools/archy/src/nav.rs
tools/archy/src/root.rs
tools/archy/src/satellites/mod.rs
tools/archy/src/theme.rs
tools/archy/src/ui.rs
tools/groxy/Cargo.lock
tools/groxy/Cargo.toml
tools/groxy/README.md
tools/groxy/extras/neovim/plugins/grok-acp-plugin/README.md
tools/groxy/extras/neovim/plugins/grok-acp-plugin/avante-grok.lua
tools/groxy/scripts/verify-nvim-avante.sh
tools/groxy/src/acp_remote.rs
tools/groxy/src/allowlist.rs
tools/groxy/src/command_parse.rs
tools/groxy/src/dm_adapter.rs
tools/groxy/src/eagle.rs
tools/groxy/src/host_job.rs
tools/groxy/src/main.rs
tools/groxy/src/outcome_package.rs
tools/groxy/src/state_store.rs
tools/groxy/tests/fixtures/inbound_status.json
tools/keeper/Cargo.lock
tools/keeper/Cargo.toml
tools/keeper/README.md
tools/keeper/docs/LOCATION.md
tools/keeper/docs/OPERATOR-MODEL.md
tools/keeper/docs/RECOVERY-CEREMONY.md
tools/keeper/docs/THREAT-MODEL.md
tools/keeper/src/ceremony.rs
tools/keeper/src/cli.rs
tools/keeper/src/crypto.rs
tools/keeper/src/factors.rs
tools/keeper/src/interactive.rs
tools/keeper/src/lib.rs
tools/keeper/src/main.rs
tools/keeper/src/store.rs
tools/keeper/src/yubi.rs
tools/keeper/tests/cli_integration.rs
vector.toml
```

</details>

## Overlap & pull candidates (Phase 1+)

| Concern | shellyxz.sh | arch-machine | packedbox target |
|---------|-------------|--------------|------------------|
| PATH contract | `core/path.contract`, `core/path.sh`, `bin/path-contract-project.sh` | — | `core/` + `installers/fix-path.sh` |
| Recovery | `bin/recover-shell.sh` | — | `core/` (Phase 1) |
| Terminal pack | tmux verify plugin, starship | Ghostty themes (`modules/productivity/eye-comfort`) | `packs/terminal/` |
| Distro install | `bin/migrate.sh`, `environments/*` | `install.sh`, `modules/*`, `adapters` N/A | `adapters/{arch,debian,ubuntu}/` |
| Native CLI/UI | — | `tools/archy` (Rust), elomaxz plans in `.grok/ideas/` | `native/packedbox-cli` (C+elomaxz), `native/packedbox-ui` (GTK4) |

---

## Phase 2 pull log (2026-09-07)

Selective copies only. Upstream repos unchanged.

### arch-machine `modules/productivity/eye-comfort` → `packs/terminal/`

| Source | Target |
|--------|--------|
| `snippets/ghostty.fragment.conf` | `ghostty/fragment.conf` |
| `tokens/roles.json` | `ghostty/roles.json` |
| `themes/eye-comfort-{dark,light,dawn,dusk}/ghostty.conf` | `ghostty/themes/.../ghostty.conf` |
| `themes/eye-comfort-{dark,light,dawn,dusk}/neovim.lua` | `nvim/themes/.../neovim.lua` |
| `nvim/omarchy-theme-hotreload.lua` | `nvim/omarchy-theme-hotreload.lua` |

**Not pulled:** `themes/**/backgrounds/*`, TN packs, waybar/units/wrappers/yazi, `lib/*.py`, `bin/eye-comfort-theme`.

### shellyxz.sh `plugins/verification` → `packs/terminal/tmux/`

| Source | Target |
|--------|--------|
| `conf/tmux.{verify,status-mode,verify-soc-theme}.conf.ex` | `tmux/conf/` |
| `data/tmux-keymaps.tsv` | `tmux/data/` |
| layout bins (`sync-tmux-verify`, `agent-*-layout`, `tmux-*`, `verify-pane-launch`) | `tmux/bin/` |
| `lib/verify-{layout,launch}.sh`, `lib/tmux-status-mode.sh` | `tmux/lib/` |

**Adapted:** managed marker + default paths → `~/.config/packedbox/packs/terminal/tmux`.

**Not pulled:** `docs/*.jpg`, cockpit-mcp, full test-discovery/`parse-project-tests` stack.
