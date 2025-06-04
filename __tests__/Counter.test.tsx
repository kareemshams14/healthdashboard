import React from 'react';
import { render, fireEvent } from '@testing-library/react';
import Counter from '../components/Counter';

test('increments count on button click', () => {
  const { getByText, getByTestId } = render(<Counter />);
  fireEvent.click(getByText('Increment'));
  expect(getByTestId('count').textContent).toBe('1');
});
