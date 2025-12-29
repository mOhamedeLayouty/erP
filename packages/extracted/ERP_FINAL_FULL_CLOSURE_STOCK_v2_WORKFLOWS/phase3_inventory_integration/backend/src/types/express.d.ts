import 'express';

declare global {
  namespace Express {
    interface User {
      user_id?: string | number;
      user_name?: string;
      username?: string;
      roles?: string[];
    }

    interface Request {
      user?: User;
    }
  }
}

export {};
