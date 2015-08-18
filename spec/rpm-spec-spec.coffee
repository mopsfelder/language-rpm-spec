#
# Copyright (c) 2015 JD Powell <waveclaw@waveclaw.net>
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.
#
# Please submit bugfixes or comments via
# https://github.com/waveclaw/language-rpm-spec/issues
#
{TextEditor} = require 'atom'
fs = require 'fs'
path = require 'path'

describe 'RPMSpec grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-rpm-spec')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.rpm-spec')

  it 'parses the grammar', ->
    expect(grammar).toBeDefined()
    expect(grammar.scopeName).toBe 'source.rpm-spec'

  it 'tokenizes metadata headers', ->
    {tokens} = grammar.tokenizeLine('Packager:')
    expect(tokens[0]).toEqual value: 'Packager:', scopes: ['source.rpm-spec',
     'keyword.rpm-spec']

  it 'tokenizes licenses', ->
    {tokens} = grammar.tokenizeLine('GPL-2.0')
    expect(tokens[0]).toEqual value: 'GPL-2.0', scopes: ['source.rpm-spec',
     'constant.language.rpm-spec']

# to be fair, I just don't get this one: why tokens[1] ==  captured null junk?
  it 'tokenizes the license header', ->
    {tokens} = grammar.tokenizeLine('License: Apache-1.1')
    expect(tokens[0]).toEqual value: 'License:', scopes: ['source.rpm-spec',
     'keyword.rpm-spec']
    expect(tokens[2]).toEqual value: 'Apache-1.1', scopes: ['source.rpm-spec',
     'constant.language.rpm-spec']

  it 'tokenizes architectures', ->
    {tokens} = grammar.tokenizeLine('x86_64')
    expect(tokens[0]).toEqual value: 'x86_64', scopes: ['source.rpm-spec',
     'constant.language.rpm-spec']

  it 'tokenizes an architectural header', ->
    {tokens} = grammar.tokenizeLine('ExclusiveArch: armv7l')
    expect(tokens[0]).toEqual value: 'ExclusiveArch:', scopes:
      ['source.rpm-spec', 'keyword.rpm-spec']
    expect(tokens[2]).toEqual value: 'armv7l', scopes: ['source.rpm-spec',
     'constant.language.rpm-spec']


  it 'tokenizes numbers', ->
    {tokens} = grammar.tokenizeLine('1234')
    expect(tokens[0]).toEqual value: '1234', scopes: ['source.rpm-spec',
     'contstant.numeric.rpm-spec']

  it 'tokenizes operators', ->
    {tokens} = grammar.tokenizeLine('>=')
    expect(tokens[0]).toEqual value: '>=', scopes: ['source.rpm-spec',
     'keyword.operator.logical.rpm-spec']

    {tokens} = grammar.tokenizeLine('||')
    expect(tokens[0]).toEqual value: '||', scopes: ['source.rpm-spec',
     'keyword.operator.logical.rpm-spec']

  it 'tokenizes section headers', ->
    {tokens} = grammar.tokenizeLine('%build')
    expect(tokens[0]).toEqual value: '%build', scopes: ['source.rpm-spec',
     'entity.name.section.rpm-spec']

    {tokens} = grammar.tokenizeLine('%post')
    expect(tokens[0]).toEqual value: '%post', scopes: ['source.rpm-spec',
     'entity.name.section.rpm-spec']

    {tokens} = grammar.tokenizeLine('%postun')
    expect(tokens[0]).toEqual value: '%postun', scopes: ['source.rpm-spec',
     'entity.name.section.rpm-spec']

    {tokens} = grammar.tokenizeLine('%description')
    expect(tokens[0]).toEqual value: '%description', scopes: ['source.rpm-spec',
     'entity.name.section.rpm-spec']

    {tokens} = grammar.tokenizeLine('%changelog')
    expect(tokens[0]).toEqual value: '%changelog', scopes: ['source.rpm-spec',
     'entity.name.section.rpm-spec']

  it 'tokenizes conditional statement parts', ->
    {tokens} = grammar.tokenizeLine('%if')
    expect(tokens[0]).toEqual value: '%if', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%ifarch')
    expect(tokens[0]).toEqual value: '%ifarch', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%ifnarch')
    expect(tokens[0]).toEqual value: '%ifnarch', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%ifnos')
    expect(tokens[0]).toEqual value: '%ifnos', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%ifos')
    expect(tokens[0]).toEqual value: '%ifos', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%else')
    expect(tokens[0]).toEqual value: '%else', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%endif')
    expect(tokens[0]).toEqual value: '%endif', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

  it 'tokenizes conditional statement parts with whitespace', ->
    {tokens} = grammar.tokenizeLine('%if ')
    expect(tokens[0]).toEqual value: '%if', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%ifarch ')
    expect(tokens[0]).toEqual value: '%ifarch', scopes: ['source.rpm-spec',
     'keyword.control.rpm-spec']

  it 'tokenizes definitions', ->
    {tokens} = grammar.tokenizeLine('%global')
    expect(tokens[0]).toEqual value: '%global', scopes: ['source.rpm-spec',
     'storage.modifier.rpm-spec']

    {tokens} = grammar.tokenizeLine('%define')
    expect(tokens[0]).toEqual value: '%define', scopes: ['source.rpm-spec',
     'storage.modifier.rpm-spec']

    {tokens} = grammar.tokenizeLine('%undefine')
    expect(tokens[0]).toEqual value: '%undefine', scopes: ['source.rpm-spec',
     'storage.modifier.rpm-spec']

  it 'tokenizes simple variables', ->
    {tokens} = grammar.tokenizeLine('%version')
    expect(tokens[0]).toEqual value: '%', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']
    expect(tokens[1]).toEqual value: 'version', scopes: ['source.rpm-spec',
     'variable.other.rpm-spec']

  it 'tokenizes questioned variables', ->
    {tokens} = grammar.tokenizeLine('%?version')
    expect(tokens[0]).toEqual value: '%?', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']
    expect(tokens[1]).toEqual value: 'version', scopes: ['source.rpm-spec',
     'variable.other.rpm-spec']

# token[0] is the pre-matched part, 3 is post matched
  it 'tokenizes variables near whitespace', ->
    {tokens} = grammar.tokenizeLine(' %version ')
    expect(tokens[1]).toEqual value: '%', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']
    expect(tokens[2]).toEqual value: 'version', scopes: ['source.rpm-spec',
     'variable.other.rpm-spec']

  it 'tokenizes variables at end of paths', ->
    {tokens} = grammar.tokenizeLine('something/%version')
    expect(tokens[1]).toEqual value: '%', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']
    expect(tokens[2]).toEqual value: 'version', scopes: ['source.rpm-spec',
     'variable.other.rpm-spec']

  it 'tokenizes complex named variables', ->
    {tokens} = grammar.tokenizeLine('%Ver_S10n')
    expect(tokens[0]).toEqual value: '%', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']
    expect(tokens[1]).toEqual value: 'Ver_S10n', scopes: ['source.rpm-spec',
     'variable.other.rpm-spec']

  it 'tokenizes variables embedded in text', ->
    {tokens} = grammar.tokenizeLine('x%{pkg_version}y')
    expect(tokens[1]).toEqual value: '%{', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']
    expect(tokens[2]).toEqual value: 'pkg_version', scopes: ['source.rpm-spec',
     'variable.other.rpm-spec']
    expect(tokens[3]).toEqual value: '}', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']

# shifting back token[0] is matched part 1, etc
  it 'tokenizes embedded variables by themselves', ->
    {tokens} = grammar.tokenizeLine('%{pkg_version}')
    expect(tokens[0]).toEqual value: '%{', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']
    expect(tokens[1]).toEqual value: 'pkg_version', scopes: ['source.rpm-spec',
     'variable.other.rpm-spec']
    expect(tokens[2]).toEqual value: '}', scopes: ['source.rpm-spec',
     'punctuation.other.bracket.rpm-spec']

  it 'tokenizes embedded variables testing for null', ->
    {tokens} = grammar.tokenizeLine('%{?pkg_version}')
    expect(tokens[0]).toEqual value: '%{?', scopes: ['source.rpm-spec',
      'punctuation.other.bracket.rpm-spec']
    expect(tokens[1]).toEqual value: 'pkg_version', scopes: ['source.rpm-spec',
      'variable.other.rpm-spec']
    expect(tokens[2]).toEqual value: '}', scopes: ['source.rpm-spec',
      'punctuation.other.bracket.rpm-spec']

  it 'tokenizes modifiers', ->
    {tokens} = grammar.tokenizeLine('%doc /foo')
    expect(tokens[0]).toEqual value: '%doc', scopes: ['source.rpm-spec',
      'storage.modifier.rpm-spec']

  it 'tokenizes nested modifiers', ->
    {tokens} = grammar.tokenizeLine('%doc %noverify(user group) /foo')
    expect(tokens[0]).toEqual value: '%doc', scopes: ['source.rpm-spec',
      'storage.modifier.rpm-spec']
# token[1] is just the whitespace
    expect(tokens[2]).toEqual value: '%noverify', scopes: ['source.rpm-spec',
      'storage.modifier.rpm-spec']

  it 'tokenizes a files list', ->
    {tokens} = grammar.tokenizeLine('%files')
    expect(tokens[0]).toEqual value: '%files', scopes: ['source.rpm-spec',
      'entity.name.section.rpm-spec']

  it 'tokenizes setup and patch', ->
    {tokens} = grammar.tokenizeLine('%setup -q')
    expect(tokens[0]).toEqual value: '%setup', scopes: ['source.rpm-spec',
      'keyword.control.rpm-spec']

    {tokens} = grammar.tokenizeLine('%patch0 -p1')
    expect(tokens[0]).toEqual value: '%patch0', scopes: ['source.rpm-spec',
      'keyword.control.rpm-spec']

  it 'tokenizes a changelog section header', ->
    {tokens} = grammar.tokenizeLine('%changelog -f my_file')
    expect(tokens[0]).toEqual value: '%changelog', scopes: ['source.rpm-spec',
      'entity.name.section.rpm-spec']

  it 'tokenizes type I changelog entries', ->
    lines = grammar.tokenizeLines '''
%changelog
* Thu Aug 13 21:31:52 UTC 2015 - jane@example.com
- I added this extra content
'''
    expect(lines[0][0]).toEqual value: '%changelog', scopes: ['source.rpm-spec',
      'entity.name.section.rpm-spec']
    expect(lines[1][1]).toEqual value: 'Thu Aug 13 21:31:52 UTC 2015', scopes:
      ['source.rpm-spec', 'constant.rpm-spec']
    expect(lines[1][3]).toEqual value: 'jane@example.com', scopes:
      ['source.rpm-spec','entity.name.rpm-spec']
    expect(lines[2][1]).toEqual value: 'I added this extra content', scopes:
      ['source.rpm-spec','comment.rpm-spec']


  it 'tokenizes type II changelog entries', ->
    lines = grammar.tokenizeLines '''
%changelog
* Sun Nov 09 2014 John Doe <john.doe@example.com> 0.40.15-2
- I added this extra content
'''
    expect(lines[0][0]).toEqual value: '%changelog', scopes: ['source.rpm-spec',
      'entity.name.section.rpm-spec']
    expect(lines[1][1]).toEqual value: 'Sun Nov 09 2014', scopes:
      ['source.rpm-spec', 'constant.rpm-spec']
    expect(lines[1][3]).toEqual value: 'John Doe', scopes:
      ['source.rpm-spec','entity.name.rpm-spec']
    expect(lines[1][5]).toEqual value: '<john.doe@example.com>', scopes:
      ['source.rpm-spec','entity.name.rpm-spec']
    expect(lines[1][7]).toEqual value: '0.40.15-2', scopes:
      ['source.rpm-spec','constant.language.rpm-spec']
    expect(lines[2][1]).toEqual value: 'I added this extra content', scopes:
      ['source.rpm-spec','comment.rpm-spec']
