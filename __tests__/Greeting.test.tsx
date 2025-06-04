import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import Greeting from '../components/Greeting';

test('renders greeting with provided name', () => {
  render(<Greeting name="Jane" />);
  expect(screen.getByRole('heading')).toHaveTextContent('Hello, Jane');
});
