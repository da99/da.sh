import { Hono } from 'hono';
import { serveStatic } from 'hono/bun';

const app = new Hono()

const public_dirs = (process.env.PUBLIC_DIRS || "Public").split(':');
app.get('/', (c) => c.text('Hono!'))

for (const i of public_dirs) {
  const [prefix, dir] = i.split('=>');
  const new_path = `${prefix}/*`;
  // app.get(new_path, serveStatic({
  //   root: i,
  //   rewriteRequestPath: (path) => path.replace(i, '')
  // }));
  app.get(new_path, async (c, next) => {
    const file_path = c.req.path.replace(prefix, dir);
    console.warn(`${c.req.path} => ${file_path}`)
    const f = Bun.file(file_path);
    if (await f.exists())
      return new Response(f);
    else
      return next();
    // return c.text(`You want public file: ${c.req.path}`)
  });
  console.warn(`new_path: ${new_path} => ${dir}`);
}

// app.get('*', (c) => c.text(c.req.path || 'unknown'))

export default app

// import { Elysia } from 'elysia'
//
// const app = new Elysia()
// .get('/', () => '? Hello Elysia')
// .listen(8080)
//
// console.log(`🦊 Elysia is running at on port ${app.server?.port}...`)
