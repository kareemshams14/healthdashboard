import React from 'react';

export interface GreetingProps {
  name: string;
}

export function Greeting({ name }: GreetingProps) {
  return <h1>Hello, {name}</h1>;
}

export default Greeting;
