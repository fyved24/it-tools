import { ArrowsShuffle } from '@vicons/tabler';
import { defineTool } from '../tool';

export const tool = defineTool({
  name: 'Javabeanstr to json',
  path: '/javabeanstr-to-json',
  description: '',
  keywords: ['javabeanstr', 'to', 'json'],
  component: () => import('./javabeanstr-to-json.vue'),
  icon: ArrowsShuffle,
  createdAt: new Date('2024-09-19'),
});