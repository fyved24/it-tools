<script setup lang="ts">
import { withDefaultOnError } from '@/utils/defaults';
import type { UseValidationRule } from '@/composable/validation';

const defaultValue = 'BaseBo(sn=123, version=1)';

function parseToJson(input: string): any {
  let pos = 0;

  function skipWhitespace() {
    while (pos < input.length && /\s/.test(input[pos])) {
      pos++;
    }
  }

  function parseValue(): any {
    skipWhitespace();
    if (pos >= input.length) {
      throw new Error('意外的输入结束');
    }
    if (input[pos] === '[') {
      return parseArray();
    } else if (/[a-zA-Z_]/.test(input[pos])) {
      return parseObjectOrIdentifier();
    } else if (input[pos] === '-' || /\d/.test(input[pos])) {
      return parseNumber();
    } else if (input.startsWith('true', pos) || input.startsWith('false', pos)) {
      return parseBoolean();
    } else if (input.startsWith('null', pos)) {
      return parseNull();
    } else {
      throw new Error('在位置 ' + pos + ' 发现意外字符：' + input[pos]);
    }
  }

  function parseArray(): any[] {
    let arr: any[] = [];
    pos++; // 跳过 '['
    skipWhitespace();
    if (pos >= input.length) {
      throw new Error('意外的输入结束');
    }
    if (input[pos] === ']') {
      pos++; // 跳过 ']'
      return arr; // 空数组
    }
    while (true) {
      let value = parseValue();
      arr.push(value);
      skipWhitespace();
      if (pos >= input.length) {
        throw new Error('意外的输入结束');
      }
      if (input[pos] === ',') {
        pos++; // 跳过 ','
        skipWhitespace();
      } else if (input[pos] === ']') {
        pos++; // 跳过 ']'
        return arr;
      } else {
        throw new Error('在位置 ' + pos + ' 期望 , 或 ]');
      }
    }
  }

  function parseObjectOrIdentifier(): any {
    let start = pos;
    while (pos < input.length && /[a-zA-Z_]/.test(input[pos])) {
      pos++;
    }
    if (start === pos) {
      throw new Error('在位置 ' + pos + ' 期望标识符');
    }
    let identifier = input.substring(start, pos);
    skipWhitespace();
    if (pos < input.length && input[pos] === '(') {
      pos++; // 跳过 '('
      return parseObjectBody(identifier);
    } else {
      // 如果没有 '('，则只是一个标识符
      return identifier;
    }
  }

  function parseObjectBody(className: string): any {
    let obj: any = {};
    obj["_class"] = className; // 包含类名
    skipWhitespace();
    if (pos >= input.length) {
      throw new Error('意外的输入结束');
    }
    if (input[pos] === ')') {
      pos++; // 跳过 ')'
      return obj; // 空对象
    }
    while (true) {
      let key = parseIdentifier();
      skipWhitespace();
      if (pos >= input.length || input[pos] !== '=') {
        throw new Error('在位置 ' + pos + ' 期望 =');
      }
      pos++; // 跳过 '='
      skipWhitespace();
      let value = parseValue();
      obj[key] = value;
      skipWhitespace();
      if (pos >= input.length) {
        throw new Error('意外的输入结束');
      }
      if (input[pos] === ',') {
        pos++; // 跳过 ','
        skipWhitespace();
      } else if (input[pos] === ')') {
        pos++; // 跳过 ')'
        return obj;
      } else {
        throw new Error('在位置 ' + pos + ' 期望 , 或 )');
      }
    }
  }

  function parseIdentifier(): string {
    let start = pos;
    while (pos < input.length && /[a-zA-Z_]/.test(input[pos])) {
      pos++;
    }
    if (start === pos) {
      throw new Error('在位置 ' + pos + ' 期望标识符');
    }
    return input.substring(start, pos);
  }

  function parseNumber(): number {
    let start = pos;
    if (input[pos] === '-') {
      pos++;
    }
    let hasDigits = false;
    while (pos < input.length && /\d/.test(input[pos])) {
      pos++;
      hasDigits = true;
    }
    if (pos < input.length && input[pos] === '.') {
      pos++;
      if (pos >= input.length || !/\d/.test(input[pos])) {
        throw new Error('在位置 ' + pos + ' 小数点后需要数字');
      }
      while (pos < input.length && /\d/.test(input[pos])) {
        pos++;
      }
    }
    if (!hasDigits) {
      throw new Error('在位置 ' + pos + ' 期望数字');
    }
    let numStr = input.substring(start, pos);
    return parseFloat(numStr);
  }

  function parseBoolean(): boolean {
    if (input.startsWith('true', pos)) {
      pos += 4;
      return true;
    } else if (input.startsWith('false', pos)) {
      pos += 5;
      return false;
    } else {
      throw new Error('在位置 ' + pos + ' 无效的布尔值');
    }
  }

  function parseNull(): any {
    if (input.startsWith('null', pos)) {
      pos += 4;
      return null;
    } else {
      throw new Error('在位置 ' + pos + ' 无效的 null 值');
    }
  }

  skipWhitespace();
  let result = parseValue();
  skipWhitespace();
  if (pos < input.length) {
    throw new Error('在位置 ' + pos + ' 发现多余的输入');
  }
  return result;
}

function isValidString(input: string): boolean {
  try {
    parseToJson(input);
    return true;
  } catch (e) {
    return false;
  }
}

function transformer(value: string) {
  return withDefaultOnError(() => {
    return JSON.stringify(parseToJson(value), null, 4);
  }, '');
}

const rules: UseValidationRule<string>[] = [
  {
    validator: isValidString,
    message: '提供的字符串格式无效。',
  },
];
</script>

<template>     
  <format-transformer
    input-label="您的 Java 字符串内容"
    :input-default="defaultValue"
    input-placeholder="在此粘贴您的 Java 字符串内容..."
    output-label="转换后的 JSON"
    output-language="json"
    :transformer="transformer"
    :input-validation-rules="rules"
  />
</template>
