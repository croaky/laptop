# Start a React Native Project

React Native is a fast and efficient way to build iOS and Android apps.

* Share code, often 80-90% of the codebase.
* The same designers and developers
  can contribute to the web app and mobile app.
* Save a file and see app reload.
* Use existing text editor.
* The compiled apps are native and performant.

This article describes a MacOS laptop setup and Vim configuration
for React Native with:

* ES6
* ESLint
* Expo
* JSX
* Jest
* Prettier
* React Navigation
* Redux
* TypeScript

## Install dependencies

Install dependencies using [Homebrew] and [NPM]:

```
brew update
brew install node
brew install watchman
brew cask install expo-xde
brew upgrade
brew cleanup
brew cask cleanup
npm install prettier --global
```

[Homebrew]: http://brew.sh/
[NPM]: https://www.npmjs.org/

## Develop using Expo XDE

[Expo] is a set of free tools that
allows us to work on JavaScript-only React Native apps
without installing XCode or Android Studio.

[Expo]: https://expo.io

[Expo XDE] was previously installed via Homebrew Cask.
Open it now.

[Expo XDE]: https://docs.expo.io/versions/v18.0.0/introduction/xde-tour.html

Create an account or sign in.
Create a new project from their dropdown menu.
This will download the appropriate files and build the project.

## Test the app on your phone

Download the [Expo Client iPhone app][client].
Open it.

From within the Expo Client app,
scan the project's QR code in the Expo XDE.

[client]: https://itunes.com/apps/exponent

Expo Client reloads the app on your phone!

## Configure your text editor

For Vim, install these [plugins]:

```
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'sbdchd/neoformat'
```

[plugins]: https://github.com/junegunn/vim-plug

Configure [Neoformat] and [Prettier]:

```vim
" Auto-format on save
augroup fmt
  autocmd!
  autocmd BufWritePre *.js,*.jsx Neoformat prettier
augroup END
```

[Neoformat]: https://github.com/sbdchd/neoformat
[Prettier]: https://github.com/prettier/prettier

## Edit the codebase in a text editor

Edit a file such as `screens/HomeScreen.js` in Vim.
Save the file.

Prettier re-formats it on save! (no linting necessary)

Expo Client reloads the app on your phone!
