import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { AuthProvider } from './contexts/AuthContext'
import { Layout } from './components/Layout'
import HomePage from './pages/HomePage'
import SuccessPage from './pages/SuccessPage'
import { ThankYou } from './pages/ThankYou'
import { PricingPage } from './pages/PricingPage'
import { LoginPage } from './pages/LoginPage'
import { SignupPage } from './pages/SignupPage'
import DashboardPage from './pages/DashboardPage'
import PartnerDashboard from './pages/PartnerDashboard'
import { WebinarBooking } from './pages/WebinarBooking'
import { WebinarRoom } from './pages/WebinarRoom'
import CleaningPage from './pages/industries/CleaningPage'
import TreePage from './pages/industries/TreePage'
import MedSpaPage from './pages/industries/MedSpaPage'
import ContractorPage from './pages/industries/ContractorPage'
import RealEstatePage from './pages/industries/RealEstatePage'
import PartnerPublicPage from './pages/PartnerPublicPage'
import EnterpriseLanding from './pages/EnterpriseLanding'
import EnterpriseReplay from './pages/EnterpriseReplay'
import EnterpriseApplication from './pages/EnterpriseApplication'
import EnterpriseOffer from './pages/EnterpriseOffer'
import './index.css'

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/" element={<Layout><HomePage /></Layout>} />
          <Route path="/login" element={<Layout><LoginPage /></Layout>} />
          <Route path="/signup" element={<Layout><SignupPage /></Layout>} />
          <Route path="/dashboard" element={<Layout><DashboardPage /></Layout>} />
          <Route path="/pricing" element={<Layout><PricingPage /></Layout>} />
          <Route path="/webinar" element={<Layout><WebinarBooking /></Layout>} />
          <Route path="/webinar/:bookingId" element={<Layout><WebinarRoom /></Layout>} />
          <Route path="/success" element={<Layout><SuccessPage /></Layout>} />
          <Route path="/thank-you" element={<Layout><ThankYou /></Layout>} />
          <Route path="/partner" element={<Layout><PartnerDashboard /></Layout>} />

          {/* Industry Landing Pages */}
          <Route path="/industries/cleaning" element={<Layout><CleaningPage /></Layout>} />
          <Route path="/industries/tree" element={<Layout><TreePage /></Layout>} />
          <Route path="/industries/medspa" element={<Layout><MedSpaPage /></Layout>} />
          <Route path="/industries/contractor" element={<Layout><ContractorPage /></Layout>} />
          <Route path="/industries/realestate" element={<Layout><RealEstatePage /></Layout>} />

          {/* Partner Public Pages */}
          <Route path="/p/:slug" element={<Layout><PartnerPublicPage /></Layout>} />

          {/* Enterprise White-Label Pages */}
          <Route path="/enterprise" element={<Layout><EnterpriseLanding /></Layout>} />
          <Route path="/enterprise/replay" element={<Layout><EnterpriseReplay /></Layout>} />
          <Route path="/enterprise/apply" element={<Layout><EnterpriseApplication /></Layout>} />
          <Route path="/enterprise/offer" element={<Layout><EnterpriseOffer /></Layout>} />
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App