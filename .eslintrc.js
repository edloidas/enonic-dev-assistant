module.exports = {
  'extends': [
    'airbnb-base',
    'prettier',
  ],
  'plugins': [
    'prettier',
  ],
  'rules': {
    'spaced-comment': [ 2, 'always', { 'exceptions': [ '-', '+' ] } ],
    'no-restricted-syntax': [ 'off' ],
    'object-property-newline': [ 'off', { 'allowMultiplePropertiesPerLine': true } ],
    'no-underscore-dangle': [ 'off' ],
    'prettier/prettier': ['error', {
      'singleQuote': true,
    }],
  },
  'env': {
    'node': true,
    'jest': true
  }
}
