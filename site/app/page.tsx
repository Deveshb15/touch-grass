import Hero from "@/components/Hero";
import Showcase from "@/components/Showcase";
import Ethos from "@/components/Ethos";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <main className="flex-1">
      <Hero />
      <Showcase />
      <Ethos />
      <Footer />
    </main>
  );
}
