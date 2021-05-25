# defbro

Change the default browser in macOS (Catalina, Big Sur).

## Installation

```
brew install jwbargsten/misc/defbro
```

## Usage

**List browsers**

```sh
defbro
```

**Change default browser**

```sh
defbro org.mozilla.firefox
```

**Toggle between Firefox and Chrome**

```bash
defbro $(defbro | grep -v "^\*" | grep "org.mozilla.firefox\|com.google.Chrome" | cut -d " " -f3)
```

**Which browser is currently not the the default**

```
defbro --json | jq -r '.[] | select(.id | contains("firefox") or contains("Chrome")) | select(.isDefault | not) | .id'
```
