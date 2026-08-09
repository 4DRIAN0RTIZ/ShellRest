# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### CI

- Split changelog/release into develop unreleased and main bump ([25e2bd4](https://github.com/4DRIAN0RTIZ/shellrest/commit/25e2bd43dda005e1e396a1fed35dd48d7374eda0))

### Documentation

- Document template rendering support ([03d2cf0](https://github.com/4DRIAN0RTIZ/shellrest/commit/03d2cf059015541cf67c9878afba8b10ccddf0b6))

### Features

- Show last-updated date in footer ([d38c95a](https://github.com/4DRIAN0RTIZ/shellrest/commit/d38c95a1762c3624a3887356951f32df5d75c51e))

## [0.5.1] - 2026-08-08

### Bug Fixes

- Return real affected-row count from db_update/db_delete ([20ff5bf](https://github.com/4DRIAN0RTIZ/shellrest/commit/20ff5bfcde56f56b1200b7c7d5a46080e4495b94))

### Refactor

- Extract data access into a model layer ([23d3a2a](https://github.com/4DRIAN0RTIZ/shellrest/commit/23d3a2ad52b71972fb531efaba2b9bb60d2b1a57))
- Extract data access into a model layer ([5d3102e](https://github.com/4DRIAN0RTIZ/shellrest/commit/5d3102eae4c736366a041ea6ff2aff9fc19479e2))
- Extract data access into a model layer ([52a2887](https://github.com/4DRIAN0RTIZ/shellrest/commit/52a28874b43e1f34c6c2205edb85a4f582a016e4))

## [0.5.0] - 2026-07-28

### Features

- Add unified artisan-style CLI entry point ([82f777c](https://github.com/4DRIAN0RTIZ/shellrest/commit/82f777cb4e70473b6396c72b4204d53f8d9df49d))

## [0.4.1] - 2026-07-28

### Chore

- Update CHANGELOG.md [skip ci] ([e04719d](https://github.com/4DRIAN0RTIZ/shellrest/commit/e04719dd5b87440da99b1e22a85ed3025380bed5))

### Testing

- Add bats test infrastructure and initial unit tests ([fed38c2](https://github.com/4DRIAN0RTIZ/shellrest/commit/fed38c279ac980450dbbc3392c5b7588424e1b81))

## [0.4.0] - 2026-07-28

### Features

- Add changelog generated from conventional commits ([df3416d](https://github.com/4DRIAN0RTIZ/shellrest/commit/df3416d8101ade92f9b01793343e343d795d146e))

## [0.3.0] - 2026-07-28

### Features

- Link 'Bash REST framework' subtitle to shellrest docs ([c3890de](https://github.com/4DRIAN0RTIZ/shellrest/commit/c3890ded4bade96ba2608209ee10d73b6cd13d7f))
- Add KPI dashboard served via template engine ([881e827](https://github.com/4DRIAN0RTIZ/shellrest/commit/881e827bca25bf8af711ab11a7719f90a1b849dd))
- Add minimal handlebars-like template engine with HTML views ([d242510](https://github.com/4DRIAN0RTIZ/shellrest/commit/d242510ac236cf2eec9f788516e0820e310de95f))

## [0.2.2] - 2026-07-25

### CI

- Add automated changelog and release workflows ([1b8bb4e](https://github.com/4DRIAN0RTIZ/shellrest/commit/1b8bb4eae2c5a14a881d5f9469c55162902e3a6a))

### Chore

- Untrack .github from gitignore ([9f3fde5](https://github.com/4DRIAN0RTIZ/shellrest/commit/9f3fde5669234b81602632f82a4f404f4d04816b))

## [0.2.1] - 2026-07-25

### Bug Fixes

- Resolve api.sh path relative to script location ([4ed3273](https://github.com/4DRIAN0RTIZ/shellrest/commit/4ed3273b2add7a04e227629f88f39b6b37b4816a))
- Remove redundant framework sourcing in route files ([3ef25c7](https://github.com/4DRIAN0RTIZ/shellrest/commit/3ef25c780ad94bf9410d3a16af5ee21fa7d18e7f))
- Use debug_log() instead of hardcoded echo to debug.log ([7c33f49](https://github.com/4DRIAN0RTIZ/shellrest/commit/7c33f49de1804821f134658ef0e19d099c60d5f7))

### Documentation

- Mark P1 and P2 as done ([ee5538c](https://github.com/4DRIAN0RTIZ/shellrest/commit/ee5538c3442d9521cd251e6065aa058597c98051))
- Mark P3/P4 done and reference fix commits ([9efaeed](https://github.com/4DRIAN0RTIZ/shellrest/commit/9efaeed1d4f91f870fb4e5f0d2eb0e1775aff817))

### Refactor

- Return last insert row ID directly from db_insert ([19226b0](https://github.com/4DRIAN0RTIZ/shellrest/commit/19226b01b093390f7e1ec5f671b9b1071f8d7d5c))
- Replace nc+FIFO with socat for request handling ([98c88b5](https://github.com/4DRIAN0RTIZ/shellrest/commit/98c88b54e9df1ab5f92e5712a10d0791b479a608))

### Merge

- Roadmap P1-P4 fixes into main ([0835b30](https://github.com/4DRIAN0RTIZ/shellrest/commit/0835b30e63c3c9707567f68ab1caf947af3cfacd))
- Bring in dirname fix from feat/socat ([9c75f6e](https://github.com/4DRIAN0RTIZ/shellrest/commit/9c75f6ed7a2a3b269a1ce02e6dc0062013a70b77))
- Bring in P2/P3/P4 roadmap fixes from fix/route-double-source ([9e72b43](https://github.com/4DRIAN0RTIZ/shellrest/commit/9e72b4317f284eb7847c7f09a159ede3785ba8b6))

## [0.2.0] - 2026-07-25

### Features

- Load sidebar version dynamically from changelog.json ([12e5f7e](https://github.com/4DRIAN0RTIZ/shellrest/commit/12e5f7ef7983d0e62b7ae3b0c57c4f18bbc06d0c))

## [0.1.0] - 2026-07-25

### Bug Fixes

- Og image updated ([4e5aece](https://github.com/4DRIAN0RTIZ/shellrest/commit/4e5aece67245fa2581a4897120731d6de9080e20))

### Chore

- Ignore .atl and .github directories ([56ce29c](https://github.com/4DRIAN0RTIZ/shellrest/commit/56ce29c2b51cca4bca89f16874320bac47ba94cc))

### Documentation

- Add i18n system with EN/ES language switcher ([532c59f](https://github.com/4DRIAN0RTIZ/shellrest/commit/532c59f0d94dce8feff1f941b968ae3ab7a720d5))
- Add Open Graph and Twitter Card meta tags ([40a9412](https://github.com/4DRIAN0RTIZ/shellrest/commit/40a94120f567368f1255f90f1351f4f61dd22d95))
- Add documentation site and update README ([6eedb16](https://github.com/4DRIAN0RTIZ/shellrest/commit/6eedb1654b3092edfca42597e5e5e275f90baa41))

### Features

- Add project scaffolding script ([4756428](https://github.com/4DRIAN0RTIZ/shellrest/commit/475642899e7cd4fcbdb89b710dc7b9e87262ab7f))
- Initial release of ShellRest ([3c9afdc](https://github.com/4DRIAN0RTIZ/shellrest/commit/3c9afdc75fc195ab51dc32f09b28b5807d8865c9))


